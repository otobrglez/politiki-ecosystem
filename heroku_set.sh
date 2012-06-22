#!/usr/bin/env bash

echo "Setting up..."

#heroku config:add POLITIKI_API_USERNAME
#heroku config:add POLITIKI_API_PASSWORD
#heroku config:add CLOUDAMQP_URL

apps=(politiki-si-scheduler politiki-si-stream-twitter politiki-si-bot-twitter politiki-si-bot-klout)
apps=(politiki-si-bot-klout)

for app in ${apps[*]}
do
	heroku config:add POLITIKI_BOT_ENV="production" --app $app
	heroku config:add POLITIKI_CONSUMER_KEY="IRwOj4FmEzOynKbjLAw" --app $app
	heroku config:add POLITIKI_CONSUMER_SECRET="yFHdLBhLICYpPHnpjbfUV2GoVghLrOOx1OnRk2g" --app $app
	heroku config:add POLITIKI_ACCESS_TOKEN="20590206-FVugwi1URMUdvAxzvYnmAr6a42GN7engiDgt9H9jM" --app $app
	heroku config:add POLITIKI_ACCESS_SECRET="0PXun6Ota7cyqM0L6VibXSifRnUg6mWuGz0t1pnAUhI" --app $app
	heroku config:add POLITIKI_KLOUT_KEY="5xfzm3meapusgzrajexpkdef" --app $app
	heroku config:add CLOUDAMQP_URL="amqp://app1538126_heroku.com:7PLzTqNTitkwiIQNyExf4fuSXVJWHk06@lemur.cloudamqp.com/app1538126_heroku.com" --app $app
done