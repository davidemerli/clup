import pytest
import json

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

from clup_server import create_app

from config import DevConfig
from clup_server.models import Store, Ticket, CLupUser, OpeningHours

@pytest.fixture(scope='session')
def flask_app():
    app = create_app(dev=True, drop_db=True)
    print('\n---FLASK APPLICATION READY')

    yield app

    print('\n---FLASK APPLICATION RELEASED')


@pytest.fixture(scope='session')
def flask_client(flask_app):
    print('\n---CREATED TEST CLIENT')
    return flask_app.test_client()

@pytest.fixture(scope='session')
def db_create():
    engine = create_engine(DevConfig.SQLALCHEMY_DATABASE_URI, echo=True)
    session_factory = sessionmaker(bind=engine)
    print('\n--- CREATE DATABASE SETTINGS')
    yield engine, session_factory

    engine.dispose()
    print('\n--- RELEASE DATABASE CONNECTION')

@pytest.fixture(scope='function')
def session(db_create):
    _, session_mkr = db_create
    session = session_mkr()
    yield session
    session.rollback()
    session.close()

@pytest.fixture(scope='session')
def populate(db_create, flask_app):
    
    db, session_mkr = db_create
    session = session_mkr()
    Base = declarative_base(bind=db)
    print(Base.metadata.tables.values())
    Base.metadata.drop_all(bind=db)
    print('\n--- WIPED DATABASE DATA')
    with open('tests/data.json') as f:
        json_string = f.read()
        data = json.loads(json_string)

    for store in data['stores']:
        session.add(Store(**store))
    
    session.commit()

    for user in data['users']:
        new_user = CLupUser(**user)
        new_user.set_password(new_user.password)
        session.add(new_user)

    session.commit()




def post_json(client,route, payload, bearer=None):
    headers = {}
    if bearer is not None:
        headers['Authorization'] = f'Bearer {bearer}'
    response = client.post(route, data=json.dumps(payload), content_type='application/json', headers=headers)
    return response

def login(client, email, password):
    payload = dict(email=email, password=password)
    response = post_json(flask_client, '/login', payload)
    if response.status_code != 200:
        raise ConnectionError('Failed to login')
    return response.json['access_token'], response.json['refresh_token']