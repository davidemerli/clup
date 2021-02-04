#!/bin/bash


docker-compose -f docker-compose-testing.yml up --build -d
cd clup-server
poetry run pytest