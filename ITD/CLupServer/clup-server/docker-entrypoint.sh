#!/bin/bash

gunicorn 'wsgi:run_app(populate=False)' --bind 0.0.0.0:8000