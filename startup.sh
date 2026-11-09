#!/bin/bash

sleep 5
pkill openrgb

# eval $(ssh-agent) > /dev/null 2>&1

rm $HOME/test.*
rm $HOME/.local/share/applications/wine*.desktop
