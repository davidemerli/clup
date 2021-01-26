from flask import request, jsonify
from flask_restful import Resource
from config import db, ma, jwt
from marshmallow import fields, validates_schema, ValidationError
from model import CLupUser, CLupUserSchema
from flask_jwt_extended import create_access_token, create_refresh_token


class Register(Resource):
    def get(self):
        content = request.json
        clup_user_schema = CLupUserSchema()
        # Validate E-mail and password fields
        errors = clup_user_schema.validate(content)
        # Create Model object
        if len(errors) > 0:
            response = {'success': False, 'errors': errors}
            return response
        else:
            clup_user = CLupUser(**content)
            clup_user.set_password(clup_user.pwd)
            # Add to databases
            db.session.add(clup_user)
            db.session.commit()
            return jsonify({'success': True, 'errors': {}})


class Login(Resource):
    def get(self):
        login_schema = LoginSchema()
        try:
            content = login_schema.load(request.json)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        access_token = create_access_token(identity=content['email'])
        refresh_token = create_refresh_token(identity=content['email'])
        return jsonify({
            'access_token': access_token,
            'refresh_token': refresh_token,
            'success': True})


class LoginSchema(ma.Schema):
    email = fields.Str(required=True)
    password = fields.Str(required=True)

    @validates_schema
    def validate_login(self, data, **kwargs):
        user = CLupUser.check_email(data['email'])
        if not user:
            raise ValidationError("Email and password don't match")
        if not user.check_password(data['password']):
            raise ValidationError("Email and password don't match")


'''
jwt_flask_extended callbacks
'''


@jwt.expired_token_loader
def expired_token_callback(expired_token):
    token_type = expired_token['type']
    return jsonify({
        'success': False,
        'errors': {
            'auth': f'The {token_type} token has expired'
        }
    }), 401


@jwt.invalid_token_loader
def invalid_token_callback(invalid_token):
    return jsonify({
        'success': False,
        'errors': {
            'auth': f'The token is invalid'
        }
    }), 401


@jwt.unauthorized_loader
def unauthorized_callback(invalid_token):
    return jsonify({
        'success': False,
        'errors': {
            'auth': f'The authorization token is missing'
        }
    }), 401
