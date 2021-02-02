from . import db, jwt, ma
from flask import request, jsonify
from flask_restful import Resource
from marshmallow import (
    fields,
    validates_schema, 
    ValidationError)
from .models import CLupUser
from .schemas import CLupUserSchema
from flask_jwt_extended import create_access_token, create_refresh_token, jwt_refresh_token_required, jwt_required, get_jwt_identity


class Register(Resource):
    def post(self):
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
            clup_user.set_password(clup_user.password)
            # Add to database
            db.session.add(clup_user)
            db.session.commit()
            return jsonify({'success': True, 'errors': {}})


class Login(Resource):

    class LoginSchema(ma.Schema):
        email = fields.Str(required=True)
        password = fields.Str(required=True)

        @validates_schema
        def validate_login(self, data, **kwargs):
            user = CLupUser.find_by_email(data['email'])
            if not user:
                raise ValidationError("Email and password don't match", "auth")
            if not user.check_password(data['password']):
                raise ValidationError("Email and password don't match", "auth")
    

    def post(self):
        login_schema = Login.LoginSchema()
        try:
            content = login_schema.load(request.json)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        user = CLupUser.find_by_email(content['email'])
        access_token = create_access_token(identity=content['email'])
        refresh_token = create_refresh_token(identity=content['email'])
        return jsonify({
            'access_token': access_token,
            'refresh_token': refresh_token,
            'clup_role': user.clup_role,
            'success': True})





class Refresh(Resource):
    class RefreshSchema(ma.Schema):
        pass


    @jwt_refresh_token_required
    def post(self):
        current_user = get_jwt_identity()
        try:
            content = Refresh.RefreshSchema().load(request.json)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        return jsonify({
            'success': True,
            'access_token' : create_access_token(identity=current_user)
        })




class AccountStatus(Resource):
    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        return jsonify({
            'login': True,
            'success': True
        })


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
