FROM hexpm/elixir:1.11.4-erlang-22.2.8-alpine-3.11.3 AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENVexport DATABASE_URL=ecto://postres:postgres@localhost/
ENV MIX_ENV=prod
#ENV DATABASE_URL="ecto://concert_finder:c34179qvx7najacp@db-postgresql-nyc3-53985-do-user-1826027-0.b.db.ondigitalocean.com:25061/bagel-tracker"
ENV SECRET_KEY_BASE="skrJe+WcTH0VNh8DYvrKVZQzobu39J68cRfDlg86jtls3ClwD2KC59aGB2lCH1JX"
ENV BAGEL_DB_PASSWORD="c34179qvx7najacp"
ENV BAGEL_SECRET="skrJe+WcTH0VNh8DYvrKVZQzobu39J68cRfDlg86jtls3ClwD2KC59aGB2lCH1JX"
ENV GEOAPI_KEY=A"IzaSyDYFpYoXsylJPkimr3IjKvUlgnGiXNNX98"
# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets

RUN npm run --prefix ./assets deploy
RUN mix phx.digest

COPY assets assets

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/bagel_tracker ./

ENV HOME=/app

CMD ["bin/bagel_tracker", "start"]