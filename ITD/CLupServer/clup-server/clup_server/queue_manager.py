from . import db, ma, jwt
from flask import request, jsonify
from flask_restful import Resource
from flask_jwt_extended import get_jwt_identity, jwt_required
from .models import Store, Ticket, CLupUser
from .schemas import TicketSchema
from marshmallow import fields, validates, ValidationError
from sqlalchemy import func


class CallFirstTicket(Resource):

    class CallFirstTicketSchema(ma.Schema):
        pass

    @jwt_required
    def post(self):
        CALL_EXPIRATION_INTERVAL = datetime.timedelta(minutes=4)

        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            _ = CallFirstTicketSchema().load(request.json)
            # User can't call a ticket
            if user.clup_role in {'OPERATOR', 'MANAGER', 'DEVICE'}:
                raise ValidationError('Not enough privileges', 'auth')
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        next_ticket = Ticket.get_next_ticket_in_line()
        if next_ticket is None:
            # No one is waiting in line
            return jsonify({
                'success': True,
                'queue_empty': True,
                'ticket': None
            })
        next_ticket.called_on = func.now()
        # Change the expiration interval
        next_ticket.expires_on = func.now() + CALL_EXPIRATION_INTERVAL
        db.session.commit()
        return jsonify({
            'success': True,
            'queue_empty': False,
            'ticket': next_ticket
        })

class AcceptTicket(Resource):

    class AcceptTicketSchema(ma.Schema):
        ticket_id = fields.Integer(required=True)
    
        @validates('ticket_id')
        def validate_ticket_id(self, ticket_id):
            ticket = Ticket.find_by_id(ticket_id)
            if ticket is None:
                raise ValidationError('ticket_id not valid', 'ticket_id')
            else:
                return ticket_id
    
    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            if user.clup_role not in {"DEVICE", "OPERATOR", "MANAGER"}:
                raise ValidationError('Not enough privileges', 'auth')
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        store = user.store
        ticket = Ticket.find_by_id()
        # Ticket must be called to enter the store
        if ticket.state != Ticket.STATE_CALLED:
            return jsonify({
                'success': False,
                'errors': {
                    'ticket': 'Ticket is not called'
                }
            }) 
        # The store must have enough capacity
        if store.real_time_capacity + 1 > store.real_time_capacity - store.reserved_capacity:
            return jsonify({
                'success': False,
                'errors': {
                    'store_capacity': 'store is full'
                }
            })
        store.real_time_capacity += 1
        ticket.used_on = func.now()
        return jsonify({
            'success': True
        })