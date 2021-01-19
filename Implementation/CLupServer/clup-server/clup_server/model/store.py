from sqlalchemy import Column, Integer, String, Boolean, Float
from sqlalchemy.orm import relationship
from config import db, ma
from .opening_hours import OpeningHours

class Store(db.Model):
    __tablename__ = 'store'

    store_id = Column(Integer, primary_key=True)
    shop_name = Column(String(255), nullable=False)
    chain_name = Column(String(255))
    country = Column(String(255), nullable=False)
    city = Column(String(255), nullable=False)
    address = Column(String(255), nullable=False)
    latitude = Column(Float(precision=32, decimal_return_scale=None), nullable=False)
    longitude = Column(Float(precision=32, decimal_return_scale=None), nullable=False)
    total_capacity = Column(Integer, nullable=False)
    reserved_capacity = Column(Integer, nullable=False, default=0)

    tickets = relationship('Ticket', back_populates='store')
    opening_hours = relationship('OpeningHours',back_populates='store')

    def __repr__(self):
        return '<Store(storeid=%d, shopname=%s, chainname=%s, address=%s %s,%s)>' % (self.store_id, self.shopename, self.chainname, self.address, self.city, self.country)