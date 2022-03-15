#!/bin/bash

# grab env variables
. .env.build

# build volume directory
mkdir -p $APP_FILES_PATH/vdirsyncer
chown -R 1000:1000 $APP_FILES_PATH/vdirsyncer
# build containers and deploy
docker-compose -f docker-compose.yaml --env-file .env.build up -d --build
# finish
exit 0
