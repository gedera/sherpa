namespace :daemon do
  desc "Exec daemon"
  task :start => :environment do |t, args|
    begin
      Daemon.new(
        name: DAEMON_NAME,
        path: Rails.root,
        daemonize: false,
        daemons_setting: YAML.load(File.read("#{Rails.root}/config/daemon_tasks.yml"))
      ).run!
    rescue => e
      puts e.message
    end
  end

  desc "Stop daemon"
  task :stop => :environment do
    daemon = Daemon.new(name: DAEMON_NAME)
    if File.exists?(daemon.pidfile)
      Process.kill("TERM", File.open(daemon.pidfile).read().to_i)
    end
  end

  desc "Restart daemon"
  task :restart => :environment do
    daemon = Daemon.new(name: DAEMON_NAME)
    if File.exists?(daemon.pidfile)
      Process.kill("TERM", File.open(daemon.pidfile).read().to_i)
    end
    start
  end
end

namespace :utils do
  desc "Show all public actions by controllers"
  task :actions => :environment do
    require 'yaml'
    @actions = {}

    Rails.application.eager_load!
    ApplicationController.descendants.each do |controller|
      @actions[controller.to_s] = controller.instance_methods(false)
    end

    File.open("actions.yml","w") do |file|
      file.write @actions.to_yaml
    end

    puts "Pls open the actions.yml file"
  end
end
