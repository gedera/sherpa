#!/usr/bin/env bash
trap finish SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Fresh install
/usr/src/app/bin/rails db:create
/usr/src/app/bin/rails db:migrate
/usr/src/app/bin/rails db:seed
/usr/src/app/bin/rails daemon:start
