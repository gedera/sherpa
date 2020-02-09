class CommandContext
  attr_accessor :commands
  attr_accessor :name
  attr_accessor :message
  cattr_accessor :run

  def initialize name, commands, message=nil, host: false
    @@run = true if @@run.nil?
    @command_logger = Rails.logger
    @commands = []
    @name = name
    @message = message
    [commands].flatten.each do |command|
      @commands << (host ? SshCommand : Command).new(command)
    end
  end

  def exec_commands(f=nil, human=nil)
    commands.each do |c|
      if @@run
        c.exec
        @command_logger.info(c.to_log.merge(name: name)) # @@command_logger.info("#{Time.zone.now}, #{name}, #{c.to_log}")
      end
      f.puts c.command if f
    end
    if @@run
      @command_logger.info({name: name, status: status}) # @command_logger.info "#{Time.zone.now}, #{name}, status: #{status}"
      human.puts "#{Time.zone.now.to_formatted_s(:db)}, #{message}, #{status}" if human
    end
    human.close if human
    status
  end

  def status
    commands.collect(&:status).sum == 0
  end

  def to_log
    {
      name:     name,
      status:   status,
      commands: commands.map(&:to_log)
    }
  end

  def to_json(*_args)
    to_log.to_json
  end
end

class BootCommandContext < CommandContext
  def self.clear_boot_file
    File.open(File.join(SCRIPTS_TMP_DIR, BOOT_FILE), 'w') do |f|
      f.truncate 0
      f.puts "#!/bin/bash"
      f.chmod 0755
    end
    File.open(COMMAND_HUMAN_LOG, 'w') {|file| file.truncate(0) }
  end

  def exec_commands
    begin
      f = File.open File.join(SCRIPTS_TMP_DIR, BOOT_FILE), "a+"
      human = File.open(COMMAND_HUMAN_LOG, "a+")
      super f, human
    rescue => e
      @command_logger.error(e)
    ensure
      f.close if f
    end
  end
end

class Command
  attr_accessor :stdout, :stderr, :pid, :command, :time, :status

  def initialize(command, opts={})
    @status = 0
    @command = command
    @timeout = opts.key?(:timeout) ? opts[:timeout] : 20
    @command_logger = Rails.logger
  end

  def build_child
    POSIX::Spawn::Child.build(command, timeout: @timeout)
  end

  def exec
    start = Time.zone.now
    child = build_child

    begin
      child.exec!
    rescue POSIX::Spawn::TimeoutExceeded => e
      @command_logger.error(e)
    ensure
      self.pid    = child&.status&.pid
      self.status = child&.status&.to_i
      self.stdout = child&.out
      self.stderr = child&.err
      self.time   = (Time.zone.now - start).round(2)
    end
  end

  def to_log
    {
      command: command,
      status:  status,
      time:    time,
      stdout:  stdout,
      stderr:  stderr,
      pid:     pid
    }
  end

  def to_json(*_args)
    to_log.to_json
  end

  def success?
    status&.zero?
  end

  def self.exec(command, opts={})
    c = self.new(command, opts)
    c.exec
    c
  end
end

class SshCommand < Command
  RSA_KEY=Rails.root.join('data', '.ssh', 'bmu-rsa')

  def build_child
    pre_command = if Rails.env.production?
                    "ssh -p 22000 -o StrictHostKeyChecking=no -i #{RSA_KEY} localhost"
                  else
                    'bash -c'
                  end

    POSIX::Spawn::Child.build("#{pre_command} '#{command}'", timeout: @timeout)
  end
end
