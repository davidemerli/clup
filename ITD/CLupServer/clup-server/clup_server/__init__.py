__version__ = "0.1.0"

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
from . import db_populate

def create_app(dev=False, drop_db=False, populate=False):
    config_path = "config.ProdConfig" if not dev else "config.DevConfig"
    print(f'Dev mode = {dev}')
    print(f'Drop Db on start = {drop_db}')
    print(f'Populate db on start = {populate}')
    app = Flask(__name__, instance_relative_config=False)
    app.config.from_object(config_path)
    print('Loaded Config')
    db.init_app(app)
    print('Initialized Database Connection')
    ma.init_app(app)
    jwt.init_app(app)
    print('Module started')
    with app.app_context():
        from . import routes

        if populate or drop_db:
            db.session.remove()
            db.drop_all()
            print('Dropped Database')

        # Generate new tables if they not exist
        db.create_all()
        print('Tables Created')
        if populate:
            db_populate.initialize_with_example_data()
            print('Data poulated')
    # For some reasons flask_restful needs to be initialized after import
    api.init_app(app)
    print('Loading complete returning app')
    return app





