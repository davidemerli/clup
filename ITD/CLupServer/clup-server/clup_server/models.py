from . import db
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    ForeignKey,
    Time,
    DateTime,
    Float,
    func,
    CheckConstraint,
)
from werkzeug.security import generate_password_hash, check_password_hash
import math
import datetime
from typing import Union


class CLupUser(db.Model):
    """
    Contains information about User, Store operators, Managers and Store
    Devices

    Maps the relation clupuser in the Database
    """

    __tablename__ = "clupuser"

    user_id = db.Column(Integer, primary_key=True)
    name = db.Column(String(255), nullable=False)
    email = db.Column(String(255), unique=True, nullable=False)
    password = db.Column(String(255), nullable=False)
    clup_role = db.Column(
        String(255),
        CheckConstraint("clup_role IN ('USER', 'OPERATOR', 'MANAGER', 'DEVICE')"),
        default="USER",
    )
    store_id = db.Column(
        Integer,
        ForeignKey("store.store_id", ondelete="cascade", onupdate="cascade"),
        nullable=True,
    )

    store = db.relationship("Store", back_populates="employees")
    tickets = db.relationship("Ticket", back_populates="user")

    __table_args__ = (CheckConstraint("(clup_role LIKE 'USER') = (store_id IS NULL)"),)

    def set_password(self, password: str) -> None:
        """
        Changes the password field of the user, hashing the password

        Uses sha256 to hash the password and automatically salts it. This method does not check the password robustness

        Parameters
        ----------
        password: str
            The new password to hash and salt.
        """
        self.password = generate_password_hash(password, "sha256")

    def check_password(self, password: str) -> bool:
        """
        Checks if the provided password matches with the hashed password of the user

        The password to check is hashed and the two hashes are compared

        Parameters
        ----------
        password: str
            The password to check

        Returns
        -------
        bool
            If the two password match True is returned
        """
        return check_password_hash(self.password, password)

    def get_active_ticket(self):
        """
        Returns a ticket not used or cancelled from the user.

        Each user could have at most one active ticket at a time

        Returns
        -------
        Ticket
            If the user has an active ticket, the function returns that Ticket object. Otherwise None is returned.
        """
        if self.clup_role != "USER":
            raise ValueError(f"{self.clup_role} can't have active tickets!")
        active = [
            ticket
            for ticket in self.tickets
            if ticket.state() in {Ticket.STATE_ISSUED, Ticket.STATE_CALLED}
        ]
        if len(active) > 0:
            return active[0]
        else:
            return None

    @classmethod
    def find_by_email(cls, address: str):
        """
        Gets the user associated with an e-mail

        E-mail is a candidate key so at most one User will be matched by e-mail.

        Parameters
        ----------
        address: str
            A valid e-mail address

        Returns
        -------
        Ticket
            If exists an user with the address provided the functions returns the corresponding
            User object, otherwise None is returned.
        """
        return cls.query.filter_by(email=address).first()

    def __repr__(self):
        return "<CLupUser(id=%d, name=%s, email=%s, pwd=%s, storeop=%s)>" % (
            self.user_id,
            self.name,
            self.email,
            self.pwd,
            self.store_op,
        )


class OpeningHours(db.Model):
    """
    Contains information about an entry of the weekly opening hours of a store

    This table is not used in the prototype
    """

    __tablename__ = "openinghours"

    entry_id = db.Column(Integer, primary_key=True)
    store_id = db.Column(
        Integer,
        ForeignKey("store.store_id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    opening_hour = db.Column(Time, nullable=False)
    opening_weekday = db.Column(Integer, nullable=False)
    closing_hour = db.Column(Time, nullable=False)
    closing_weekday = db.Column(Integer, nullable=False)

    store = db.relationship("Store", back_populates="opening_hours")

    __table_args__ = (
        CheckConstraint(
            "(opening_weekday BETWEEN 1 AND 7) AND (closing_weekday BETWEEN 1 AND 7)"
        ),
        CheckConstraint(
            "closing_weekday > opening_weekday OR (closing_weekday = opening_weekday AND closing_hour > opening_hour)"
        ),
    )


class Store(db.Model):
    """
    Contains details about a Store.

    Contains details about location, capacity of the store. Maps the relation "store" in the
    database
    """

    __tablename__ = "store"

    store_id = db.Column(Integer, primary_key=True)
    store_name = db.Column(String(255), nullable=False)
    chain_name = db.Column(String(255))
    country = db.Column(String(255), nullable=False)
    city = db.Column(String(255), nullable=False)
    address = db.Column(String(255), nullable=False)
    latitude = db.Column(Float(precision=32, decimal_return_scale=None), nullable=False)
    longitude = db.Column(
        Float(precision=32, decimal_return_scale=None), nullable=False
    )
    total_capacity = db.Column(Integer, nullable=False)
    reserved_capacity = db.Column(Integer, nullable=False, default=0)
    real_time_capacity = db.Column(Integer, nullable=False, default=0)

    tickets = db.relationship("Ticket", back_populates="store")
    opening_hours = db.relationship("OpeningHours", back_populates="store")
    employees = db.relationship("CLupUser", back_populates="store")

    __table_args__ = (CheckConstraint("reserved_capacity < total_capacity"),)

    def __repr__(self):
        return "<Store(id=%d, name=%s, latitude=%f, longitude=%f)>" % (
            self.store_id,
            self.store_name,
            self.latitude,
            self.longitude,
        )

    def get_queue(self):
        """
        Returns the status of the queue of the people with tickets waiting to
        enter the store

        Only ticket not canceled and not called to enter are considered queued

        Returns
        -------
        list[Ticket]
            Returns a list of Ticket objects sorted by issue timestamp (Ascending)
        """
        return sorted(
            (
                ticket
                for ticket in self.tickets
                if ticket.state() == Ticket.STATE_ISSUED
            ),
            key=lambda x: x.issued_on,
        )

    @classmethod
    def find_by_id(cls, store_id):
        """
        Gets the user associated with an e-mail

        The Id is the primary key so it's unique.

        Parameters
        ----------
        store_id: int
            A positive integer

        Returns
        -------
        Ticket
            If exists a Store with the provided id the function returns the corresponding
            Ticket object, otherwise None is returned.
        """
        return Store.query.get(store_id)

    @classmethod
    def get_all_stores_radius(cls, origin: tuple, radius: float) -> list:
        """
        Returns all stores details within a certain radius

        Parameters
        ----------
        origin: tuple[float]
            A tuple containing GPS Coordinates (latitude, longitude)
        radius: float
            The search radius. Store out of this radius will not be listed in the
            results
        Returns
        -------
        Ticket
            If exists a Store with the provided id the function returns the corresponding
            Ticket object, otherwise None is returned.
        """
        return [x for x in cls.query.all() if x.gps_distance(*origin) < radius]

    def gps_distance(self, latitude: float, longitude: float) -> float:
        # Earth radius in meters
        R = 6372800
        lat1, lon1 = self.latitude, self.longitude
        lat2, lon2 = latitude, longitude

        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        dphi = math.radians(lat2 - lat1)
        dlambda = math.radians(lon2 - lon1)

        a = (
            math.sin(dphi / 2) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
        )
        dist = 2 * R * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        return dist


class Ticket(db.Model):
    """
    Contains details about a Ticket needed to enter the store.

    A ticket could be in different states:
    - ISSUED: Ticket is issued, the holder is waiting outside the store
    - CALLED: An Operator called the ticket call number, the holder should
    reach the store entrance and scan the ticket to enter
    - EXPIRED: The ticket has passed its expiration time and could not be
    used to enter. When a ticket is called its expiration date is reduced
    - USED: An Operator/Access Controller scanned the ticket. The holder has
    entered the store
    - CANCELLED: The holder (customer) cancelled the ticket. The ticket is no
    longer valid
    """

    # Maximum value for human readable ticket call number
    MAX_CALL_NUMBER = 999
    # The duration of a ticket
    EXPIRATION_INTERVAL = datetime.timedelta(hours=1)
    # State enumeration
    STATE_ISSUED = 1
    STATE_CALLED = 2
    STATE_EXPIRED = 3
    STATE_USED = 4
    STATE_CANCELLED = 5

    __tablename__ = "ticket"

    ticket_id = db.Column(Integer, primary_key=True)
    store_id = db.Column(
        Integer,
        ForeignKey("store.store_id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    issued_on = db.Column(DateTime(timezone=True), default=func.now())
    called_on = db.Column(DateTime(timezone=True))
    expires_on = db.Column(
        DateTime(timezone=True), nullable=False, default=func.now() + EXPIRATION_INTERVAL
    )
    used_on = db.Column(DateTime(timezone=True))
    is_virtual = db.Column(Boolean, nullable=False)
    cancelled_on = db.Column(DateTime(timezone=True))
    user_id = db.Column(
        Integer,
        ForeignKey("clupuser.user_id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    call_number = db.Column(Integer, nullable=False)

    store = db.relationship("Store", back_populates="tickets")
    user = db.relationship("CLupUser", back_populates="tickets")

    __table_args__ = (
        CheckConstraint(
            "is_virtual = false AND user_id IS NULL OR is_virtual = true AND user_id IS NOT NULL"
        ),
    )

    @classmethod
    def find_by_id(cls, ticket_id):
        """
        Gets a ticket by its ticket id

        The Id is the primary key so it's unique.

        Parameters
        ----------
        ticket_id: int
            A positive integer

        Returns
        -------
        Ticket
            If exists a Ticket with the provided id the function returns the corresponding
            Ticket object, otherwise None is returned.
        """
        return Ticket.query.get(ticket_id)

    def is_called(self):
        """
        Returns true if the ticket was called to enter
        """
        return self.called_on is not None

    def is_used(self):
        """
        Returns true if the ticket was scanned to enter
        """
        return self.used_on is not None

    def is_expired(self):
        """
        Returns true if the ticket passed its expiration date
        """
        return (
            db.session.query(Ticket.expires_on <= func.now())
            .filter_by(ticket_id=self.ticket_id)
            .first()[0]
        )

    def is_cancelled(self):
        """
        Returns true if the user cancelled its
        """
        return self.cancelled_on is not None

    def state(self):
        """
        Returns the current state of the ticket based on the events happened
        to the ticket

        Returns
        -------
        int
            The number corresponding to the actual state of the ticket
            The constans declared in the class could be used to reference
            the ticket states
        """
        # Define a priority network
        if self.is_cancelled():
            return Ticket.STATE_CANCELLED
        elif self.is_used():
            return Ticket.STATE_USED
        elif self.is_expired():
            return Ticket.STATE_EXPIRED
        elif self.is_called():
            return Ticket.STATE_CALLED
        else:
            return Ticket.STATE_ISSUED

    # Precondition: Store ID Exists
    @classmethod
    def get_next_call_number(cls, a_store_id: int) -> int:
        """
        Returns the call identifier of the ticket.

        The call identifier is used to give an human readable
        identifier to store operators and customer

        Parameters
        ----------
        a_store_id : int
        The store referred

        Returns
        -------
        int
        The number that will be assigned to the next ticket created in the store
        """

        last_ticket_in_store = (
            db.session.query(func.max(Ticket.issued_on))
            .filter_by(store_id=a_store_id)
            .subquery()
        )

        value = (
            db.session.query(Ticket.call_number)
            .filter_by(store_id=a_store_id)
            .filter(Ticket.issued_on >= last_ticket_in_store)
            .first()
        )

        if value is None:
            return 1
        else:
            return (value[0] + 1) % cls.MAX_CALL_NUMBER

    @classmethod
    def get_queue(cls, a_store_id: int):
        """
        Get tickets id in a store queue


        Parameters
        ----------
        a_store_id : int
        The store for which retrieve the queue

        Returns
        -------
        list[int]
        Returns a list with all ticket ids in the queue order
        """
        queue = (
            db.session.query(Ticket.ticket_id)
            .filter_by(store_id=a_store_id)
            .filter(Ticket.called_on == None)
            .filter(func.now() <= Ticket.expires_on)
            .filter(Ticket.cancelled_on == None)
            .filter(Ticket.used_on == None)
            .order_by(Ticket.issued_on.asc())
            .all()
        )
        return [item[0] for item in queue]

    @classmethod
    def get_called(cls, a_store_id: int):
        """
        Get tickets id called to enter in a given store

        Parameters
        ----------
        a_store_id : int
        The store for which retrieve the called ticket list

        Returns
        -------
        list[int]
        Returns a list with all ticket ids called to enter
        """
        called = (
            db.session.query(Ticket.ticket_id)
            .filter_by(store_id=a_store_id)
            .filter(Ticket.called_on != None)
            .filter(func.now() <= Ticket.expires_on)
            .filter(Ticket.cancelled_on == None)
            .filter(Ticket.used_on == None)
            .order_by(Ticket.called_on.asc())
            .all()
        )
        return [item[0] for item in called]

    @classmethod
    def get_next_ticket_in_line(cls, a_store_id: int):
        """
        Returns the call identifier of the ticket.

        The call identifier is used to give an human readable
        identifier to store operators and customer

        Parameters
        ----------
        a_store_id : int
        The store referred

        Returns
        -------
        int
        The number that will be assigned to the next ticket created in the store
        """
        queue = cls.get_queue(a_store_id)

        if len(queue) == 0:
            return None
        else:
            return Ticket.find_by_id(queue[0])

    @classmethod
    def get_position_in_line(self, a_store_id, timestamp=func.now()) -> int:
        """
        Get the number of tickets actually in line issued before a timestamp

        Parameters
        ----------
        a_store_id : int
        The store for which the position is required

        timestamp : datetime
        The timestamp from which the position in line is calculated

        Returns
        -------
        int
        A strictly positive integer representing the position in line.
        """
        count = (
            db.session.query(Ticket.ticket_id)
            .filter_by(store_id=a_store_id)
            .filter(Ticket.called_on == None)
            .filter(func.now() <= Ticket.expires_on)
            .filter(Ticket.cancelled_on == None)
            .filter(Ticket.used_on == None)
            .filter(Ticket.issued_on < timestamp)
            .count()
            + 1
        )
        return count
