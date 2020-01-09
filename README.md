# Sherpa skeleton service

# New service
```bash
cd /path
git clone git@github.com:sequre/sherpa.git
cd sherpa
ruby start_new_service.rb  # you have to answer with the CamelCase and snake_case new service name
```

# Setup

## Initialize docker services

### Make sure that our [docker_services](https://github.com/sequre/docker_services) is up an ready. You can check with:

```bash
$> docker-compose ps
           Name                         Command               State
--------------------------------------------------------------------------------------------------
dockerservices_postgres_1    docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp
dockerservices_redis_1       docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
dockerservices_sentry_1      /entrypoint.sh /run_sentry.sh    Up      0.0.0.0:9000->9000/tcp
dockerservices_wisproMQ1_1   docker-entrypoint.sh rabbi ...   Up      15671/tcp, 0.0.0.0:15672->15
```

You must see:
- **dockerservices_postgres_1**  State Up (Postgres service)
- **dockerservices_redis_1**     State Up (Redis service)
- **dockerservices_sentry_1**    State Up (Sentry service)
- **dockerservices_wisproMQ1_1** State Up (Rabbit service)

## Install bundle

```bash
$> cd ~/Sherpa
$> gem install bundle
$> bundle install
```

## ENV file

### Install [direnv](https://direnv.net/)

### Configure envs

```bash
$> cd ~/Sherpa
$> touch .envrc
```

Inside the file _.envrc_ (or whatever env file you like), set:

```bash
# This is an example for development environment. You can use whatever you like.
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sherpa
DB_USER=sherpa
DB_PASS=sherpa
RABBIT_USER=wisproMQ
RABBIT_PASS=wisproMQ
RABBIT_HOST=localhost
RABBIT_VIRTUAL_HOST=sync.devel
IV_ENCRYPTER="REPLACE_WITH_ENCODED_IV"
KEY_ENCRYPTER="REPLACE_WITH_ENCODED_KEY"
```

 **IMPORTANT** After initialize or update the file _.envrc_.

```bash
cd ../Sherpa # This is for upload the rbvenv-vars
```

## Configure Postgres for AFIP Service

### Create user

```bash
$> cd ~/docker_services
$> ./run_in_service.sh postgres bash
$> psql -U postgres
CREATE USER sherpa WITH PASSWORD 'sherpa';
```
### Create database

```bash
$> cd ~/docker_services
$> ./run_in_service.sh postgres bash
$> psql -U postgres
CREATE DATABASE sherpa;
```

### Grant permission to user

```bash
$> cd ~/docker_services    # If use postgres docker service
$> ./run_in_service.sh postgres bash # If use postgres docker service
$> psql -U postgres
GRANT ALL PRIVILEGES ON DATABASE DB_NAME TO sherpa;
ALTER DATABASE DB_NAME OWNER TO sherpa;
ALTER ROLE sherpa SUPERUSER;
```

### Migrate database

```bash
$> rake db:migrate
```

## Set Rabbit user permission
- Visit http://localhost:15672/
- username: **RABBIT_USER**
- password: **RABBIT_PASS**
- Go to Admin tab
- On the right click on "Virtual Hosts"
- Click on the **RABBIT_VIRTUAL_HOST** created
- Set permission to **RABBIT_USER**

# Debugging

```bash
$> rails console
```
# Testing

For testing use:

```bash
$> rails test
```

# Running
```bash
$> rake init_consumer[queue]
```
