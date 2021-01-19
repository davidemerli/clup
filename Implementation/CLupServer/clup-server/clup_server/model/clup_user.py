from sqlalchemy import Column, Integer, String, Boolean, Float
from sqlalchemy.orm import relationship
from marshmallow import validates, ValidationError
from config import db, ma
from .ticket import Ticket

class CLupUser(db.Model):
    __tablename__ = 'clupuser'

    user_id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    pwd = Column(String(255), nullable=False)
    store_op = Column(Boolean, nullable=False, default=False) 

    tickets = relationship('Ticket', back_populates='user')

    @classmethod
    def email_already_exists(cls, email):
        return cls.query.filter_by(email=email).first() is not None
    
    @classmethod
    def validate_password(cls, password):
        #TODO
        return True
    


    def __repr__(self):
        return '<CLupUser(id=%d, name=%s, email=%s, pwd=%s, storeop=%s)>' % (self.user_id, self.name, self.email, self.pwd, self.store_op)


class CLupUserSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = CLupUser
        include_fk = True
        load_instance = True
    
    @validates('email')
    def validate_email(self, value):
        if '@' not in value:
            raise ValidationError('Email format invalid.')
        return value