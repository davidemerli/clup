FROM python:3.9.1-slim-buster

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . /clup-server

EXPOSE 8000

ARG populate=False

ENV POPULATE=$populate

WORKDIR /clup-server

ENTRYPOINT ["./docker-entrypoint.sh"]