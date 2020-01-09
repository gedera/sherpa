# frozen_string_literal: true

namespace :job do
  @settings = YAML.safe_load(
    File.read(Rails.root.join('config', 'daemon_tasks.yml'))
  )

  @settings.keys.each do |daemon_name|
    desc "Exec #{daemon_name.underscore.tr('_', ' ')}"
    task daemon_name.underscore => :environment do |_t, args|
      setting = @settings[daemon_name]

      Signal.trap('INT') { exit }

      daemon = daemon_name.constantize.new(
        setting.merge(
          start_now: true,
          break_consumer: args.break.present?
        )
      )
      daemon.call
    end
  end
end
