class DaemonTask
  def initialize(setting={})
    raise "Please define name key for #{self.class.name} in config/daemon_tasks.yml" unless setting['name']
    @name = setting['name'].underscore.downcase if setting['name']
    @time_for_exec = {}
    @daemon_logger = ::SherpaLogger.new(
      name: @name,
      level_log: setting.fetch('level_log', :debug)
    )
    @exec_as_process = setting['exec_as_process'].present?

    @priority = setting.has_key?('priority') ? setting['priority'].to_i : -5
    @attr_daemon_time = "#{@name}_next_exec_time" # ESTO AHORA HAY QUE VERLO. POR QUE SI VA COMO CRON NO VA HACER MAS FALTA, SE SIMPLIFICA, POR QUE ERA UN PERNO ESTO.
    @next_exec = Time.now
    @time_for_exec[:start_now] = setting.key?('start_now') && setting['start_now']

    if setting['frecuency']
      @time_for_exec[:frecuency] = eval(setting['frecuency'])
      init_next_execution_time
    end
  end

  def exec_command(command)
    result = Command.new(command)
    result.exec
    @daemon_logger.debug("[EXEC_COMMAND] command: #{command}, pid: #{result.to_log[:pid]}, stdout: #{result.to_log[:stdout]}, stderr: #{result.to_log[:stderr]}")
    result.to_log
  end

  def stop
    @exec_as_process ? stop_process : stop_thread
  end

  def stop_thread
    @thread_daemon.exit
    @daemon_logger.info('[STOP]')
  rescue Exception => e
    @daemon_logger.error(e)
  end

  def stop_process
    @daemon_logger.info("[SEND_SIGNAL_TERM] #{@name} (#{pid})")
    Process.kill('TERM', pid)
    status = Process.wait2(pid).last
    @daemon_logger.info("[WAITH_FOR_DAEMON_PROCESS] NAME: #{name} PID: #{status.pid} EXITSTATUS: #{status.exitstatus.inspect}")
  end

  # ESTO AHORA HAY QUE VERLO. POR QUE SI VA COMO CRON NO VA HACER MAS FALTA, SE SIMPLIFICA, POR QUE ERA UN PERNO ESTO.
  def init_next_execution_time
    if Daemon.respond_to?(@attr_daemon_time) and not Daemon.send(@attr_daemon_time).nil?
      @next_exec = Daemon.send(@attr_daemon_time)
    else
      @next_exec = @time_for_exec.has_key?(:begin_in) ? Time.parse(@time_for_exec[:begin_in], Time.new) : Time.now
      unless @time_for_exec[:start_now]
        @next_exec += @time_for_exec[:frecuency] if Time.now > @next_exec
      end
    end
  end

  def set_next_execution_time
    while @next_exec <= Time.now
      @next_exec += @time_for_exec[:frecuency]
    end

    if Daemon.respond_to?(@attr_daemon_time)
      $update_execution.synchronize {
        Daemon.send("#{@attr_daemon_time}=", @next_exec)
        Daemon.save
        @daemon_logger.debug("Initialize next exec time for: #{@next_exec}")
      }
    end
  end

  def start; @exec_as_process ? start_as_process : start_as_thread; end

  def start_as_thread
    @thread_daemon = Thread.new do
      Thread.current['name'] = @name
      Thread.current.priority = @priority
      loop do
        begin
          if Time.now >= @next_exec
            report = nil
            Benchmark.bm do |x|
              report = x.report {
                # Daemon.reload
                set_next_execution_time if @time_for_exec[:frecuency]
                call
                @daemon_logger.debug("[NEXT_EXEC_TIME] #{@next_exec}")
              }
            end
            @daemon_logger.info("[REPORT_DAEMON_EXEC] USER_TIME: #{report.utime.to_f.round(1)}, TOTAL_TIME: #{report.total.to_f.round(1)}, REAL_TIME: #{report.real.to_f.round(1)}")
          end
        rescue => e
          @daemon_logger.error(e)
        end
        to_sleep
      end
    end
  end

  def start_as_process
    process_name = "#{DAEMON_NAME}_#{@name.underscore}"
    pidof_command = POSIX::Spawn::Child.build("pidof #{process_name}", timeout: 20)
    pidof_command.exec!
    pid = POSIX::Spawn.`("pidof #{process_name}").chomp
      Process.kill('KILL', pid.to_i) unless pid.blank?
      ::ActiveRecord::Base.clear_all_connections!
      @thread_daemon = fork do
        begin
          $0 = process_name
          ::ActiveRecord::Base.establish_connection
          #Process.setpriority(Process::PRIO_PROCESS, 0, @priority) if Rails.env.production?
          @condition = true
          Signal.trap('TERM') { @condition = false }
          while @condition
            if Time.now >= @next_exec
              report = nil
              Benchmark.bm do |x|
                report = x.report {
                  call
                  set_next_execution_time  if @time_for_exec[:frecuency]
                  @daemon_logger.debug("[NEXT_EXEC_TIME] #{@next_exec}")
                }
              end
              @daemon_logger.info("[REPORT_DAEMON_EXEC] USER_TIME: #{report.utime}, TOTAL_TIME: #{report.total}, REAL_TIME: #{report.real}")
            end
            to_sleep
          end
        rescue => e
          @daemon_logger.error(e)
        end
      end
    end

    def pid
      @exec_as_process ? @thread_daemon : $?.pid
    end

    def name
      @name
    end

    def join
      @thread_daemon.join
    end

    def thread
      @thread_daemon
    end

    def to_sleep
      time_to_sleep = ((@next_exec.to_i - Time.now.to_i) <= 0)? 0.5 : (@next_exec.to_i - Time.now.to_i)
      sleep [time_to_sleep, 5].min
    end

    def running?
      @exec_as_process ? process_running? : thread_running?
    end

    def is_a_process?
      @exec_as_process
    end

    def thread_running?
      !@thread_daemon.status.nil?
    end

    def process_running?
      Process.wait2(pid, Process::WNOHANG).nil?
    end
  end
