from . import ma, db, jwt
from .models import CLupUser, Store, Ticket
from marshmallow import validates, ValidationError
from email_validator import EmailNotValidError, validate_email
from werkzeug.security import generate_password_hash, check_password_hash

special_symbols = set("*.!@#$%^&(){}[]:;<>,.?/~_+-=|\\")
PASSWORD_MIN_LENGTH = 8


class CLupUserSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = CLupUser
        include_fk = True
        load_instance = True

    @validates("email")
    def validate_mail(self, value):
        try:
            valid = validate_email(value, check_deliverability=False)
        except EmailNotValidError as e:
            raise ValidationError(str(e))
        if CLupUser.find_by_email(value) is not None:
            raise ValidationError("E-Mail is already used")
        return valid.email

    @validates("password")
    def validate_lower(self, value):
        errors = []
        if not any(c.islower() for c in value):
            errors.append("Password must contain at least one lower case " "letter")
        if not any(c.isupper() for c in value):
            errors.append("Password must contain at least one upper case " "letter")
        if not any(c.isdigit() for c in value):
            errors.append("Password must contain at least one digit")
        if not len(value) >= PASSWORD_MIN_LENGTH:
            errors.append("Password must be at least 8 characters long")
        if not any(c in special_symbols for c in value):
            errors.append("Password must contain at least one special symbol")
        if errors:
            raise ValidationError(errors)
        return value


class StoreSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Store
        include_fk = True
        load_instance = True


class TicketSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Ticket
        include_fk = True
        load_instance = True
