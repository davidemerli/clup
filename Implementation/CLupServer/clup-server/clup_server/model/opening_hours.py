from sqlalchemy import Column, Integer, Time, ForeignKey
from sqlalchemy.orm import relationship
from config import db, ma

class OpeningHours(db.Model):
    __tablename__ = 'openinghours'

    entry_id = Column(Integer, primary_key=True)
    store_id = Column(Integer,
        ForeignKey('store.store_id', ondelete='CASCADE', onupdate='CASCADE'),
        nullable=False)
    opening_hour = Column(Time, nullable=False)
    opening_weekday = Column(Integer, nullable=False)
    closing_hour = Column(Time, nullable=False)
    closing_weekday = Column(Integer, nullable=False)

    store = relationship('Store', back_populates='opening_hours')