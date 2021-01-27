from flask import request, jsonify
from flask_restful import Resource
from flask_jwt_extended import get_jwt_identity, jwt_required
from model import Store, Ticket, TicketSchema, CLupUser
from config import db, ma, jwt
from marshmallow import fields, validates, ValidationError
from sqlalchemy import func


class CreateTicket(Resource):
    @jwt_required
    def get(self):
        user_email = get_jwt_identity()
        try:
            content = CreateTicketSchema().load(request.json)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        store_id = content['store_id']
        user = CLupUser.find_by_email(user_email)
        is_virtual = not user.store_op
        if is_virtual:
            # Check if the user has other active tickets
            print(f'\n-----------prove: {user.tickets}')
            if any(True for ticket in user.tickets if ticket.state() == Ticket.STATE_ISSUED or ticket.state() == Ticket.STATE_CALLED):
                return jsonify({
                    'success': False,
                    'errors': {
                        'ticket': 'Ticket already created'
                    }
                })
        next_call_number = Ticket.get_next_call_number(store_id)
        new_ticket = Ticket(user_id=user.user_id, store_id=store_id, is_virtual=is_virtual, call_number=next_call_number)
        # Add to database
        # try:
        db.session.add(new_ticket)
        db.session.commit()
        return jsonify({
            'success': True,
            'ticket': TicketSchema().dump(new_ticket)
        })




class CreateTicketSchema(ma.Schema):
    store_id = fields.Integer(required=True)


    @validates('store_id')
    def validate_storeID(self, value):
        if Store.query.get(value) is None:
            raise ValidationError('Store ID not valid')
        return value

class TicketOperationSchema(ma.Schema):
    ticket_id = fields.Integer(required=True)

    @validates('ticket_id')
    def validate_ticket_id(self, value):
        if Ticket.query.get(value) is None:
            raise ValidationError('Ticket ID not valid')
        return value