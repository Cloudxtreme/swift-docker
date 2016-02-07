#! /bin/bash

APP=$1
CONTAINER=$APP
CONTAINER+=_app_development

shift
COMMAND=$*
COMMAND=${COMMAND:-bash}

docker exec -it $CONTAINER /bin/bash -lc "cd /var/apps/$APP; $COMMAND"