import pytest
import psycopg2
import sqlalchemy
import sys

def test_driver_connection():
    conn = psycopg2.connect(database="CLup", user="postgres",password="postgres", host="127.0.0.1", port="5432")
    cur = conn.cursor()
    r = cur.execute("SELECT * FROM clupuser")

def test_sql_alchemy():
    db = sqlalchemy.create_engine('postgresql://postgres:postgres@127.0.0.1:5432/CLup', echo=True)
    with db.connect() as connection:
        result = db.execute("SELECT * FROM clupuser")
    for row in result:
        print("name:", row['firstname'])