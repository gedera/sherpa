FROM ruby:2.6.3-alpine3.8

# Patch to get global bins
ENV BUNDLE_BIN="$GEM_HOME/bin"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$BUNDLE_BIN"
RUN chmod 777 "$BUNDLE_BIN"

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc

RUN apk --update add --virtual build-dependencies \
    build-base mysql-dev mariadb-dev git openssh && \
    apk --update add bash tzdata nano mariadb-connector-c curl && \
    gem install bundler

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install --deployment --jobs 5 \
    && apk del build-dependencies

ADD . ./

CMD ["/usr/src/app/bin/docker-cmd-server.sh"]
