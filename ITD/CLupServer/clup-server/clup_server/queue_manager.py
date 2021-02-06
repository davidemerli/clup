from . import db, ma, jwt
from flask import request, jsonify
from flask_restful import Resource
from flask_jwt_extended import get_jwt_identity, jwt_required
from .models import Store, Ticket, CLupUser
from .schemas import TicketSchema
from marshmallow import fields, validates, ValidationError
from sqlalchemy import func
import datetime


class CallFirstTicket(Resource):
    class CallFirstTicketSchema(ma.Schema):
        pass

    @jwt_required
    def post(self):
        CALL_EXPIRATION_INTERVAL = datetime.timedelta(minutes=4)

        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            _ = CallFirstTicket.CallFirstTicketSchema().load(request.json)
            # User can't call a ticket
            if user.clup_role not in {"OPERATOR", "MANAGER", "DEVICE"}:
                raise ValidationError("Not enough privileges", "auth")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        next_ticket = Ticket.get_next_ticket_in_line(user.store.store_id)
        if next_ticket is None:
            # No one is waiting in line
            return jsonify({"success": True, "queue_empty": True, "ticket": None})
        next_ticket.called_on = func.now()
        # Change the expiration interval
        next_ticket.expires_on = func.now() + CALL_EXPIRATION_INTERVAL
        db.session.commit()
        next_ticket_data = TicketSchema().dump(next_ticket)
        return jsonify(
            {"success": True, "queue_empty": False, "ticket": next_ticket_data}
        )


class AcceptTicket(Resource):
    class AcceptTicketSchema(ma.Schema):
        ticket_id = fields.Integer(required=True)

        @validates("ticket_id")
        def validate_ticket_id(self, ticket_id):
            ticket = Ticket.find_by_id(ticket_id)
            if ticket is None:
                raise ValidationError("ticket_id not valid", "ticket_id")
            else:
                return ticket_id

    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            content = AcceptTicket.AcceptTicketSchema().load(request.json)
            if user.clup_role not in {"DEVICE", "OPERATOR", "MANAGER"}:
                raise ValidationError("Not enough privileges", "auth")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        store = user.store
        ticket = Ticket.find_by_id(content["ticket_id"])
        # Ticket must be called to enter the store
        if ticket.state() != Ticket.STATE_CALLED:
            return jsonify(
                {"success": False, "errors": {"ticket": "Ticket is not called"}}
            )
        if ticket.store.store_id != store.store_id:
            return jsonify(
                {
                    "success": False,
                    "errors": {"ticket": "Ticket is bound to another store"},
                }
            )
        # The store must have enough capacity
        if store.real_time_capacity + 1 > store.reserved_capacity:
            return jsonify(
                {"success": False, "errors": {"store_capacity": "store is full"}}
            )
        store.real_time_capacity += 1
        ticket.used_on = func.now()
        db.session.commit()
        return jsonify(
            {"success": True, "real_time_capacity": store.real_time_capacity}
        )


class CountStoreLeave(Resource):
    class CountStoreLeaveSchema(ma.Schema):
        pass

    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            CountStoreLeave.CountStoreLeaveSchema().load(request.json)
            if user.clup_role not in {"DEVICE", "OPERATOR", "MANAGER"}:
                raise ValidationError("Not enough privileges", "auth")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        store = user.store
        if store.real_time_capacity <= 0:
            return jsonify(
                {"success": False, "errors": {"store": "No customer inside store"}}
            )
        store.real_time_capacity -= 1
        db.session.commit()
        return jsonify({"success": True, "current_capacity": store.real_time_capacity})


class QueueStatus(Resource):
    class QueueStatusSchema(ma.Schema):
        pass

    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)
        try:
            QueueStatus.QueueStatusSchema().load(request.json)
            if user.clup_role not in {"DEVICE", "OPERATOR", "MANAGER"}:
                raise ValidationError("Not enough privileges", "auth")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        store = user.store
        queued_tickets = Ticket.get_queue(store.store_id)
        queued_call_numbers = [Ticket.find_by_id(ticked_id).call_number for ticked_id in queued_tickets]
        called_tickets = Ticket.get_called(store.store_id)
        called_call_numbers = [Ticket.find_by_id(ticked_id).call_number for ticked_id in called_tickets]
        return jsonify(
            {
                "success": True,
                "queue_length": len(queued_tickets),
                "called_tickets": len(called_tickets),
                "queue_ticket_ids": queued_tickets,
                "queued_call_numbers": queued_call_numbers,
                "called_ticket_ids": called_tickets,
                "called_call_numbers": called_call_numbers
            }
        )
