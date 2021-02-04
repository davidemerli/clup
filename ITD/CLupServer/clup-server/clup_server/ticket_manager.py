from . import db, ma, jwt
from flask import request, jsonify
from flask_restful import Resource
from flask_jwt_extended import get_jwt_identity, jwt_required
from .models import Store, Ticket, CLupUser
from .schemas import TicketSchema
from marshmallow import fields, validates, ValidationError
from sqlalchemy import func


class CreateTicket(Resource):
    class CreateTicketSchema(ma.Schema):
        store_id = fields.Integer(required=True)

        @validates("store_id")
        def validate_storeID(self, value):
            if Store.query.get(value) is None:
                raise ValidationError("Store ID not valid")
            return value

    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        try:
            content = CreateTicket.CreateTicketSchema().load(request.json)
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        store_id = content["store_id"]
        user = CLupUser.find_by_email(user_email)
        is_virtual = user.clup_role == "USER"
        if is_virtual:
            # Check if the user has other active tickets
            if any(
                True
                for ticket in user.tickets
                if ticket.state() == Ticket.STATE_ISSUED
                or ticket.state() == Ticket.STATE_CALLED
            ):
                return jsonify(
                    {"success": False, "errors": {"ticket": "Ticket already created"}}
                )
        next_call_number = Ticket.get_next_call_number(store_id)
        new_ticket = Ticket(
            user_id=user.user_id,
            store_id=store_id,
            is_virtual=is_virtual,
            call_number=next_call_number,
        )
        # Add to database
        db.session.add(new_ticket)
        db.session.commit()
        # Add position in queue
        ticket_obj = TicketSchema().dump(new_ticket)
        ticket_obj["line_position"] = Ticket.get_position_in_line(
            new_ticket.store.store_id, new_ticket.issued_on
        )

        return jsonify({"success": True, "ticket": ticket_obj})


class CancelTicket(Resource):
    class CancelTicketSchema(ma.Schema):
        ticket_id = fields.Integer(required=False)

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
            content = CancelTicket.CancelTicketSchema().load(request.json)
            if "ticket_id" in content:
                # Users must not supply a ticket id
                # The currently active ticket will be considered
                if user.clup_role not in {"OPERATOR", "MANAGER", "DEVICE"}:
                    raise ValidationError("ticket_id not required", "ticket_id")
                else:
                    ticket = Ticket.find_by_id(ticket_id)
            else:
                if user.clup_role in {"OPERATOR", "MANAGER", "DEVICE"}:
                    raise ValidationError("ticket_id required", "ticket_id")
                else:
                    ticket = user.get_active_ticket()
                    if ticket is None:
                        raise ValidationError("no active ticket for the user", "ticket")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})

        ticket.cancelled_on = func.now()
        db.session.commit()
        return jsonify({"success": True})


class GetActiveTicket(Resource):
    class GetActiveTicketSchema(ma.Schema):
        pass

    @jwt_required
    def post(self):
        user_email = get_jwt_identity()
        user = CLupUser.find_by_email(user_email)

        try:
            _ = GetActiveTicket.GetActiveTicketSchema().load(request.json)
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        ticket = user.get_active_ticket()
        if ticket is not None:
            ticket_obj = TicketSchema().dump(ticket)
            ticket_obj["line_position"] = Ticket.get_position_in_line(
                ticket.store.store_id, ticket.issued_on
            )
        else:
            ticket_obj = None
        return jsonify({"success": True, "ticket": ticket_obj})


class TicketInfo(Resource):
    class TicketInfoSchema(ma.Schema):
        ticket_id = fields.Integer(required=False)

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
            content = TicketInfo.TicketInfoSchema().load(request.json)
            if user.clup_role not in {"DEVICE", "OPERATOR", "MANAGER"}:
                raise ValidationError("Not enough privileges", "auth")
        except ValidationError as err:
            return jsonify({"success": False, "errors": err.messages})
        store = user.store
        ticket = Ticket.find_by_id(content["ticket_id"])
        if ticket.store_id != store.store_id:
            return jsonify(
                {"success": False, "errors": {"auth": "Not enough privileges for hth"}}
            )
        ticket_obj = TicketSchema().dump(ticket)
        if ticket.state() == Ticket.STATE_ISSUED:
            ticket_obj["line_position"] = Ticket.get_position_in_line(
                ticket.store.store_id, ticket.issued_on
            )
        else:
            ticket_obj["line_position"] = 0

        return jsonify({"success": True, "ticket": ticket_obj})
