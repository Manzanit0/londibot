# Londibot

[![Build Status](https://travis-ci.org/Manzanit0/londibot.svg?branch=master)](https://travis-ci.org/Manzanit0/londibot)
[![Coverage Status](https://coveralls.io/repos/github/Manzanit0/londibot/badge.svg?branch=master)](https://coveralls.io/github/Manzanit0/londibot?branch=master)

Bot which reports the status of London TFL services.

Available in Telegram: [link](https://t.me/LondiBot)

## What is Londibot?

Londibot started as a wrapper around the TFL API so would get aquainted with Clojure when I first arrived to London (Autumn 2018), but as
I spent more time in the city, I realized that the public transport services were slightly underwhelming – it's not unusual for any underground
line to suffer delays a couple of times a day. That's when I decided that the TFL API wrapper could actually be so much more and help me with that
struggle.

Currently, Londibot is a Telegram/Slack bot which allows users to subscribe to any underground/overground line so it notifies them upon any service
change, be it a disruption or a recovery. It supports a wide variety of commands, all the way from `/status` to `/subscribe Victoria, Metropolitan`.

## And technically, how is it structured?

Since Londibot has been the application through which I have gottent aquainted with Elixir (it started as Clojure, but ((((¯\_(ツ)_/¯))))), it has
suffered many major changes. Currently Londibot is structured in two major sections – core and web.

Londibot core contains a set of modules which:
- Connect with TFL API via HTTP
- CRUDs subscriptions to transport lines
- Notifies users via the specified channel (Telegram/Slack) upon status changes

While Londibot web simply contains a web handler which parses and dispatches incoming requests from the set up webhooks.

## Getting started

Simply clone the repository and run:

```
mix deps
mix run --no-halt
```

To run the tests, run: `mix test`.
