from flask import request, abort, jsonify
from flask_restful import Resource
from config import db
from model import CLupUser, CLupUserSchema

class Register(Resource):
    def post(self):
        content = request.json
        clup_user_schema = CLupUserSchema()
        error_msg = {}
        # Validate E-mail and password fields
        errors = clup_user_schema.validate(content)
        if errors:
            error_msg |= errors
        # Validate E-mail uniqueness (query database)
        if CLupUser.email_already_exists(content['email']):
            error_msg |= {'email':'E-Mail already exists.'}
        #Create Model object
        if len(error_msg) > 0:
            response = {'success': False, 'errors': error_msg}
            return response
        clup_user = CLupUser(**content)
        #Add to databases
        db.session.add(clup_user) 
        db.session.commit()
        return jsonify({'success': True, 'errors': {}})
