class DaemonTelegramBot < ::DaemonTask
  def initialize(setting)
    super(setting)
  end

  def call
    @daemon_logger.debug("DaemonTelegramBot")
    TelegramBot.run!
  end
end
