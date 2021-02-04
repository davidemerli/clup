from . import db
from .models import CLupUser, Store
import json

def initialize_with_example_data():
    with open("data.json") as f:
        json_string = f.read()
        data = json.loads(json_string)
    
    for store in data["stores"]:
        db.session.add(Store(**store))

    db.session.commit()

    for user in data["users"]:
        new_user = CLupUser(**user)
        new_user.set_password(new_user.password)
        db.session.add(new_user)

    db.session.commit()
