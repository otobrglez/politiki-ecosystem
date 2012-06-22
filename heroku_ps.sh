#!/usr/bin/env bash

apps=(politiki-si-scheduler politiki-si-stream-twitter politiki-si-bot-twitter politiki-si-bot-facebook)

for app in ${apps[*]}
do
	heroku ps --app $app
done