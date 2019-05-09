FROM ruby:2.4.1-alpine

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc

RUN apk --update add --virtual build-dependencies \
    build-base postgresql-dev git openssh && \
    apk --update add libpq bash tzdata vim nano && \
    gem install bundler

RUN mkdir -p /root/.ssh/
COPY ./docker-rsa /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa && ssh-keyscan github.com >> /root/.ssh/known_hosts

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install --deployment --jobs 5 \
    && apk del build-dependencies

ADD . ./

CMD ["rake", "consume", "--", "-m", "sync"]
