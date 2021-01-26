from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Time, DateTime, Float
from werkzeug.security import generate_password_hash, check_password_hash
from config import db
import math

class CLupUser(db.Model):
    __tablename__ = 'clupuser'

    user_id = db.Column(Integer, primary_key=True)
    name = db.Column(String(255), nullable=False)
    email = db.Column(String(255), unique=True, nullable=False)
    password = db.Column('pwd', String(255), nullable=False)
    store_op = db.Column(Boolean, nullable=False, default=False)

    tickets = db.relationship('Ticket', back_populates='user')

    def set_password(self, password):
        self.password = generate_password_hash(password, "sha256")

    def check_password(self, password):
        return check_password_hash(self.password, password)

    @classmethod
    def check_email(cls, address):
        return cls.query.filter_by(email=address).first()

    def __repr__(self):
        return '<CLupUser(id=%d, name=%s, email=%s, pwd=%s, storeop=%s)>' % \
            (self.user_id, self.name, self.email, self.pwd, self.store_op)




class OpeningHours(db.Model):
    __tablename__ = 'openinghours'

    entry_id = db.Column(Integer, primary_key=True)
    store_id = db.Column(Integer,
                      ForeignKey('store.store_id',
                                 ondelete='CASCADE',
                                 onupdate='CASCADE'),
                      nullable=False)
    opening_hour = db.Column(Time, nullable=False)
    opening_weekday = db.Column(Integer, nullable=False)
    closing_hour = db.Column(Time, nullable=False)
    closing_weekday = db.Column(Integer, nullable=False)

    store = db.relationship('Store',
                         back_populates='opening_hours')


class Store(db.Model):
    __tablename__ = 'store'

    store_id = db.Column(Integer, primary_key=True)
    shop_name = db.Column(String(255), nullable=False)
    chain_name = db.Column(String(255))
    country = db.Column(String(255), nullable=False)
    city = db.Column(String(255), nullable=False)
    address = db.Column(String(255), nullable=False)
    latitude = db.Column(Float(precision=32, decimal_return_scale=None),
                      nullable=False)
    longitude = db.Column(Float(precision=32, decimal_return_scale=None),
                       nullable=False)
    total_capacity = db.Column(Integer, nullable=False)
    reserved_capacity = db.Column(Integer, nullable=False, default=0)

    tickets = db.relationship('Ticket', back_populates='store')
    opening_hours = db.relationship('OpeningHours', back_populates='store')

    def __repr__(self):
        return '<Store(id=%d, name=%s, latitude=%f, longitude=%f)>' % \
            (self.store_id, self.shop_name, self.latitude, self.longitude)

    @classmethod
    def get_all_stores_radius(cls, origin, radius):
        print(radius)
        return [x for x in cls.query.all() if x.gps_distance(*origin) < radius]

    def gps_distance(self, latitude, longitude):
        # Earth radius in meters
        R = 6372800
        lat1, lon1 = self.latitude, self.longitude
        lat2, lon2 = latitude, longitude

        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        dphi = math.radians(lat2 - lat1)
        dlambda = math.radians(lon2 - lon1)

        a = math.sin(dphi/2)**2 + \
            math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
        dist = 2*R*math.atan2(math.sqrt(a), math.sqrt(1 - a))
        print(dist)
        return dist




class Ticket(db.Model):
    __tablename__ = 'ticket'

    ticket_id = db.Column(Integer, primary_key=True)
    store_id = db.Column(Integer,
                      ForeignKey('store.store_id', ondelete='CASCADE',
                                 onupdate='CASCADE'),
                      nullable=False)
    emitted_on = db.Column(DateTime)
    called_on = db.Column(DateTime)
    expires_on = db.Column(DateTime)
    used_on = db.Column(DateTime)
    is_virtual = db.Column(Boolean, nullable=False)
    cancelled_on = db.Column(DateTime)
    user_id = db.Column(Integer,
                     ForeignKey('clupuser.user_id', ondelete='CASCADE',
                                onupdate='CASCADE'),
                     nullable=False)

    store = db.relationship('Store',  back_populates='tickets')
    user = db.relationship('CLupUser', back_populates='tickets')
