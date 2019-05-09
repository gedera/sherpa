class Daemon

  $update_execution = Mutex.new

  # PID_PATH = "#{#Rails.root.to_s}/tmp/pids/"
  PID_PATH = "tmp/pids/"

  attr_reader :options, :term, :daemons_setting

  def initialize(options={})
    raise 'We need a name' unless (options[:name])
    @name = options[:name].underscore.downcase
    @term = false
    @path = options[:daemons_setting] || Dir.pwd
    @daemons = []
    @daemonize = options.has_key?(:daemonize) ? options[:daemonize] : false
    @daemon_logger = ::SherpaLogger.new(
      name: @name,
      level_log: options.fetch(:level_log, :debug)
    )
    @daemons_setting = options[:daemons_setting]
  end

  def logfile; @daemon_logger.log_file_path; end # options[:logfile]

  def pidfile; [PID_PATH, @name].join(''); end # options[:pidfile]

  def daemonize
    return unless @daemonize
    @daemon_logger.info "DEMONIZE"
    Process.daemon
    Dir.chdir @path
  end

  def trap_signals; trap(:TERM) { @term = true }; end # graceful shutdown of run! loop

  def init_daemons
    @daemons_setting.each do |daemon_task, setting|
      begin
        @daemon_logger.info("[INIT_DAEMON] #{daemon_task}")
        @daemon_logger.info("[#{daemon_task}] setting: #{setting}")
        daemon = daemon_task.constantize.new(setting)
        # daemon = DaemonTask.new(setting)
        @daemons << daemon
        daemon.start
      rescue => e
        @daemon_logger.error(e)
      end
    end
  end

  def check_daemons
    while !@term
      @daemons.each do |daemon|
        unless daemon.running?
          begin
            daemon.start
            @daemon_logger.debug("[RESTART_DAEMON] #{daemon.name}")
          rescue => e
            @daemon_logger.error(e)
          end
        end
      end
      sleep 1
    end
  end

  def stop_daemons
    @daemons.select{|d| not d.is_a_process?}.each do |daemon|
      daemon.stop
      @daemon_logger.info("[WAITH_FOR_DAEMON_THREAD] #{daemon.name}")
      daemon.join
    end

    @daemons.select(&:is_a_process?).each { |daemon| daemon.stop; sleep 3 }
  end

  def run!
    $0 = DAEMON_NAME
    @daemon_logger.info "CHECK PID"
    check_pid
    daemonize
    @daemon_logger.info "WRITE PID"
    write_pid
    @daemon_logger.info "TRAP SIGNALS"
    trap_signals
    # suppress_output
    # redirect_output

    begin
      @daemon_logger.info "INITIALIZE DAEMONS"
      init_daemons
      @daemon_logger.info "MONITORING DAEMONS"
      check_daemons
      stop_daemons
    #      File.open(@file_with_end_execution_time, 'a+'){ |f| f.puts DateTime.now.to_s }
    rescue Exception => e
      @daemon_logger.error(e)
    ensure
      FileUtils.rm_f pidfile
    end
  end

  def write_pid
    begin
      FileUtils.mkdir_p(PID_PATH)
      File.open(pidfile, ::File::CREAT | ::File::EXCL | ::File::WRONLY){|f| f.write("#{Process.pid}") }
      FileUtils.chmod 0755, pidfile
      at_exit { File.delete(pidfile) if File.exists?(pidfile) }
    rescue Errno::EEXIST
      check_pid
      retry
    end
  end

  def check_pid
    case pid_status(pidfile)
    when :running, :not_owned
      puts "A server is already running. Check #{pidfile}"
      @daemon_logger.info("A server is already running. Check #{pidfile}")
      exit(1)
    when :dead
      File.delete(pidfile)
    end
  end

  def pid_status(pidfile)
    return :exited unless File.exists?(pidfile)
    pid = ::File.read(pidfile).to_i
    return :dead if pid == 0
    Process.kill(0, pid) # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end

  # def redirect_output
  #   # FileUtils.mkdir_p(File.dirname(logfile), :mode => 0755)
  #   # FileUtils.touch logfile
  #   # File.chmod(0666, logfile)
  #    $stderr.reopen(logfile, 'a')
  #    $stdout.reopen(logfile, 'a')
  #   # $stdout.reopen($stderr)
  #   $stdout.sync = $stderr.sync = true
  # end

  # def suppress_output
  #   $stderr.reopen('/dev/null', 'a')
  #   $stdout.reopen($stderr)
  # end
end
