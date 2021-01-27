from flask import Flask
from flask_restful import Api
from flask_sqlalchemy import SQLAlchemy 
from flask_marshmallow import Marshmallow
from flask_jwt_extended import JWTManager

app = Flask(__name__)
api = Api(app)

# Configure the SQLAlchemy part of the app instance
app.config['SQLALCHEMY_ECHO'] = True
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'postgresql://postgres:postgres@127.0.0.1:5432/CLup'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'super-secret'

# Create the SQLAlchemy db instance
db = SQLAlchemy(app)

# Create flask Marshmallow instance 
ma = Marshmallow(app)

# Create JWT Manager
jwt = JWTManager(app)


