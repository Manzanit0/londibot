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

Since Londibot has been the application through which I have gotten aquainted with Elixir (it started as Clojure, but ((((¯\_(ツ)_/¯))))), it has
suffered many major changes. Currently Londibot is structured in different blocks.

- **TFL**, takes care of connecting via HTTP with the TFL API and adding the logic of which statuses are good, bad, etc.
- **Subscriptions**, is in charge of handling user subscriptions to lines. It saves and queries them.
- **Notifications** is one of the bigger blocks. It contains the different wrappers for the Slack/Telegram messaging APIs as well as a worker
which polls TFL and discerns when to send a message or not.
- **Commands** contains the logic to be executed for each command sent to the bot.
- **Web** is basically the handlers of the webhooks for the Slack and Telegram APIs.

## Using Londibot

Currently Londibot supports multiple commands, slightly different across services to improve UX.

### Telegram

In case you're using the Telegram bot, different slash commands have been provided to make the bot more discoverable.

- `/status` will respond with a brief summary of all lines' status, like the dashboard you can find in the subway.
- `/disruptions` will respond just with the current disruptions in all the transport network
- `/subscriptions` will respond with a list of lines to which you are subscribed
- `/subscribe circle, london overground` will subscribe to the given lines
- `/unsubscribe victoria, northern` will unsubscribe to the given lines

### Slack

To use Londibot via Slack, a slash command has been set up: `/londibot`. I have opted for having a single slash command since often 
Slack installations will have many bots and having too many slash commands ends up in being more confusing.

- `/londibot status` will respond with a brief summary of all lines' status, like the dashboard you can find in the subway.
- `/londibot disruptions` will respond just with the current disruptions in all the transport network
- `/londibot subscriptions` will respond with a list of lines to which you are subscribed
- `/londibot subscribe circle, london overground` will subscribe to the given lines
- `/londibot unsubscribe victoria, northern` will unsubscribe to the given lines

## Getting started

Simply clone the repository and run:

```
mix deps
mix run --no-halt
```

To run the tests, run: `mix test`.

### Setting up the DB

To save user subscriptions, I've decided to go with Postgres (PG). Before continuing, make sure you have a running instance in your computer.
In case you're running MacOS, I find it very convenient to use homebrew services to start and stop the DB:

Starting PG: `brew services start postgresql`
Stoping PG: `brew services stop postgresql`

Once you have the PG up and running, to create the DB run: `mix ecto.create && mix ecto.migrate` (make sure to have a user `postgres` without password and superuser role).