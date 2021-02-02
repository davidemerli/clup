__version__ = '0.1.0'

from flask import Flask
from flask_restful import Api
from flask_sqlalchemy import SQLAlchemy 
from flask_marshmallow import Marshmallow
from flask_jwt_extended import JWTManager

db = SQLAlchemy()
api = Api()
ma = Marshmallow()
jwt = JWTManager()

from . import models
from . import auth_manager
from . import information_provider
from . import ticket_manager


def create_app(dev=False, drop_db=False):
    config_path = "config.ProdConfig" if not dev else "config.DevConfig"
    app = Flask(__name__, instance_relative_config=False)
    app.config.from_object(config_path)

    db.init_app(app)

    ma.init_app(app)
    jwt.init_app(app)

    with app.app_context():
        from . import routes
        
        if drop_db:
            db.drop_all()

        # Generate new tables if they not exist
        db.create_all()  

    # For some reasons flask_restful needs to be initialized after import
    api.init_app(app)

    return app