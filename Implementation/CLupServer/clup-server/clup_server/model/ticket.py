from sqlalchemy import Column, Integer, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from config import db, ma
from .store import Store


class Ticket(db.Model):
    __tablename__ = 'ticket'

    ticket_id = Column(Integer, primary_key=True)
    store_id = Column(Integer, 
        ForeignKey('store.store_id', ondelete='CASCADE', onupdate='CASCADE'),
        nullable=False)
    emitted_on = Column(DateTime)
    called_on = Column(DateTime)
    expires_on = Column(DateTime)
    used_on = Column(DateTime)
    is_virtual = Column(Boolean, nullable=False)
    cancelled_on = Column(DateTime)
    user_id = Column(Integer, 
        ForeignKey('clupuser.user_id', ondelete='CASCADE', onupdate='CASCADE'),
        nullable=False)

    store = relationship('Store',  back_populates='tickets')
    user = relationship('CLupUser', back_populates='tickets')