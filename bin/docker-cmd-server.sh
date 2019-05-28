#!/usr/bin/env bash
server_pid="/tmp/rails.pid"

finish() {
  if [ -f $server_pid ]; then
    pid=$(cat $server_pid)

    if [ $pid -ne 0 ]; then
      kill -SIGINT $pid
      wait $pid
    fi
  fi
  exit 143
}
trap finish SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Fresh install
rails db:create
rails db:migrate

rails db:seed

bundle exec rails daemon:start &
wait $!
