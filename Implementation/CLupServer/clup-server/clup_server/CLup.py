from flask_restful import Api, Resource
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from api import Register
from config import app, api
import model


api.add_resource(Register,'/register')


if __name__ == '__main__':
    #TODO: Remove this in production
    app.config["DEBUG"] = True
    app.run()
