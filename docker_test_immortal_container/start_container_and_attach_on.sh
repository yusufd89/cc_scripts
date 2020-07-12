#!/bin/sh

cp "./../cc_scripts.sh" .

docker build -t "cc_scripts_immortal_container" .

CONTAINER_ID=$(docker run -dit "cc_scripts_immortal_container")

docker exec -i -t "$CONTAINER_ID" bash
