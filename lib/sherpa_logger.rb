class SherpaLogger
  require 'fileutils'

  # Definido un cierto tipo de logger, solo escribiran los metodos superiores a ese logger.
  # Ejemplo si se define como logger level ERROR solo se resgistrara lo que escriba el metodo .error(), pero no el .info(), .debug() y .warn()

  # UNKNOWN # An unknown message that should always be logged.
  # FATAL   # An unhandleable error that results in a program crash.
  # ERROR   # A handleable error condition.
  # WARN    # A warning.
  # INFO    # Generic (useful) information about system operation.
  # DEBUG   # Low-level information for developers.

  # FOREGROUND COLOR
  F_BLACK   = "\033[30m"
  F_RED     = "\033[31m"
  F_GREEN   = "\033[32m"
  F_YELLOW  = "\033[33m"
  F_BLUE    = "\033[34m"
  F_MAGENTA = "\033[35m"
  F_CYAN    = "\033[36m"
  F_WHITE   = "\033[37m"

  # BACKGROUND COLOR
  B_BLACK     = "\033[40m"
  B_RED       = "\033[41m"
  B_GREEN     = "\033[42m"
  B_YELLOW    = "\033[43m"
  B_BLUE      = "\033[44m"
  B_MAGENTA   = "\033[45m"
  B_CYAN      = "\033[46m"
  B_WHITE     = "\033[47m"

  CLOSE_COLOR = "\033[0m"

  attr_accessor :log, :with_color

  def initialize(opts={})
    raise 'We need a name' unless (_name = opts[:name])

    if (priority = opts[:priority])
      priority    = F_GREEN + priority.to_s + CLOSE_COLOR
    end

    if (process_id = opts[:process_id])
      process_id = F_WHITE + Process.pid.to_s + CLOSE_COLOR
    end

    @with_color = !Rails.env.production? rescue true
    @with_color = opts[:colorize] if opts.has_key?(:colorize)

    # Esto es para que por defecto largue los logs por stdout pero para que tambien los largue en el archivo. 2 x 1
    FileUtils::mkdir_p "#{ENV['LOG_DIR'] || 'log/'}" # Explota si no esta el dir log

    @_ruby_logger = ::Logger.new(STDOUT)  # native logger

    @log = if opts[:stdout] || ENV['LOGS_TO_STDOUT']
             STDOUT.sync = true
             ::Logger.new(STDOUT)
           else
             ::Logger.new("#{ ENV['LOG_DIR'] || 'log/' }#{_name}.log", 7, 10485760)  # 10.megabytes
           end

    @log.level = :debug
    @log.level = ENV['LOG_LEVEL'].to_sym unless ENV['LOG_LEVEL'].nil?
    @log.level = opts[:level_log] if opts.has_key?(:level_log)

    log.formatter = proc do |severity, datetime, progname, msg|
      date     = colorize(datetime.in_time_zone('Buenos Aires').strftime('%Y-%m-%d %H:%M:%S'), F_YELLOW) rescue colorize(datetime.strftime('%Y-%m-%d %H:%M:%S'), F_YELLOW)
      hostname = colorize(Socket.gethostname, F_GREEN)
      name     = colorize(_name.to_s, F_CYAN)
      method   = colorize((progname[1] || 'main').to_s, F_GREEN)
      msg      = colorize(msg.to_s, F_WHITE)
      severity = severity_color(severity)

      [
        hostname,
        date,
        priority,
        (process_id ? "(#{process_id})" : nil),
        "[#{severity}] [#{name}] [in: #{method}] #{msg} \n"
      ].compact.join(' ')
    end

    log
  end

  def colorize(line, color=F_WHITE)
    @with_color ? (color + line + CLOSE_COLOR) : line
  end

  def severity_color(severity)
    color = case severity
            when 'INFO'
              F_GREEN
            when 'DEBUG'
              F_BLUE
            when 'ERROR'
              F_RED
            when 'WARN'
              F_YELLOW
            else
              F_WHITE
            end
    colorize(severity, color)
  end

  def level=(level)
    @log.level=level
  end

  def level; log.level; end

  def formatter; log.formatter; end

  def prog_method_name(name); name.split("/").last.scan(/(.*)\.rb.*:in `(.*)'/).flatten; end

  def info(message=nil); log.info(prog_method_name(caller[0])){message}; end

  def debug(message=nil); log.debug(prog_method_name(caller[0])){message}; end

  def warn(message=nil); log.warn(prog_method_name(caller[0])){message}; end

  def error(exception, caller_number=1)
    progname = prog_method_name(caller[caller_number])
    exc = if exception.respond_to?(:backtrace)  # backtrace is only for exceptions
            # ::Sherpa::Sentry.notify(exception) rescue nil # si explota no calienta
            ::Exception.new(exception)
            exception
          else
            ::Exception.new(exception)
          end

    log.error(progname) { [exc.message, exc.verbose_backtrace].compact.join("\n") }
  end

  alias_method :fatal, :error

  def method_missing(m, *args, &block)
    @_ruby_logger.send(m, *args, &block)
  end

  ##### Helpers
  def self.to_log(data)
    case data.class
    when Array
      data.map {|d| "[ #{self.to_log(d)} ]" }.join(', ')
    when Hash
      data.map {|k, v| "{ #{k}: #{self.to_log(d)} }" }.join(', ')
    else
      data.to_s
    end
  end
end
