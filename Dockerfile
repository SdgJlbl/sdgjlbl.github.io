FROM ruby

WORKDIR /code

ADD Gemfile .
ADD Gemfile.lock .

RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "--livereload", "--incremental"]
