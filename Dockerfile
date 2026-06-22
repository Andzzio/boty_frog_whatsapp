FROM dart:stable AS build

WORKDIR /app

RUN dart pub global activate dart_frog_cli

COPY pubspec.yaml ./
RUN dart pub get

COPY . .

RUN /root/.pub-cache/bin/dart_frog build

RUN dart compile exe build/bin/server.dart -o /server

FROM debian:stable-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=build /server /server

EXPOSE 8081
CMD ["/server"]
