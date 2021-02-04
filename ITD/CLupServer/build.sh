#!/bin/sh

export JWT_SECRET_KEY='change_this_sdada'
if [ $JWT_SECRET_KEY = 'change_this_plz' ]; then
    echo 'Please change the jwt secret'
    exit
fi
docker-compose up --build