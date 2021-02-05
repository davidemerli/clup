from os import environ, path
from dotenv import load_dotenv

basedir = path.abspath(path.dirname(__file__))
load_dotenv(path.join(basedir, '.env'))

class Config:
    FLASK_APP = environ.get('FLASK_APP')
    JWT_SECRET_KEY = environ.get('JWT_SECRET_KEY')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    FLASK_APP='CLup' 

class DevConfig(Config):
    FLASK_ENV = 'development'
    DEBUG = True
    TESTING = True
    JWT_SECRET_KEY = 'random_for_testing'
    #SQLALCHEMY_ECHO = True
    SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:postgres@127.0.0.1:5432/clup_test'

class ProdConfig(Config):
    FLASK_ENV = 'production'
    DEBUG = False
    TESTING = False
    PROPAGATE_EXCEPTIONS = True
    SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:postgres@postgres:5432/clup'