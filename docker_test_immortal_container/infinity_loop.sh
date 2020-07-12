#!/bin/sh

while true; do
    sleep 10
    echo "background"
done &

while true; do
    sleep 10
    echo "foreground"
done
