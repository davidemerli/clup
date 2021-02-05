#!/bin/bash

gunicorn 'wsgi:run_app(populate=True)' --bind 0.0.0.0:8000
