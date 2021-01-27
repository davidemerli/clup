
DROP SCHEMA public CASCADE;

CREAte SCHEMA public;

START TRANSACTION;

CREATE TABLE clupuser
(
    user_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    pwd text NOT NULL,  --TODO: Change this when my own crypto is rolled
    clup_role varchar(255) NOT NULL DEFAULT "USER",
    store_id INTEGER,
    FOREIGN KEY (store_id) REFERENCES clupuser(store_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT valid_role CHECK clup_role IN ("USER", "OPERATOR", "MANAGER", "DEVICE")
    CONSTRAINT store_ref CHECK clup_role != "USER" AND 
);

CREATE TABLE store
(
    store_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    shop_name varchar(255) NOT NULL,
    chain_name varchar(255),
    country varchar(255) NOT NULL,
    city varchar(255) NOT NULL,
    address varchar(255)  NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    total_capacity integer NOT NULL,
    reserved_capacity integer NOT NULL,
    realtime_capacity integer DEFAULT 0
    CONSTRAINT reservedcapacity 
        CHECK (reserved_capacity < total_capacity)

);

CREATE TABLE openinghours
(
    entry_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    store_id integer NOT NULL,
    opening_weekday integer NOT NULL,
    opening_hour time NOT NULL,
	closing_weekday integer NOT NULL,
    closing_hour time NOT NULL,
    FOREIGN KEY (store_id) REFERENCES store(store_id) 
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT day1_to_7 CHECK (opening_weekday BETWEEN 1 AND 7 AND closing_weekday BETWEEN 1 AND 7),
    CONSTRAINT close_gt_open 
		CHECK (closing_weekday > opening_weekday 
			   OR (closing_weekday = opening_weekday AND closing_hour > opening_hour))
);

CREATE TABLE ticket
(
    ticket_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    store_id integer NOT NULL,
    emitted_on timestamp NOT NULL DEFAULT now(),
    called_on timestamp ,
    expires_on timestamp ,
    used_on timestamp ,
    is_virtual boolean NOT NULL,
    cancelled_on timestamp,
    user_id integer NOT NULL,
    FOREIGN KEY (user_id) REFERENCES clupuser(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (store_id) REFERENCES store(store_id) 
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT virtual_has_owner 
		CHECK ((is_virtual = false and user_id is null) or (is_virtual = true and user_id is not null))
);
COMMIT;

START TRANSACTION;
COPY clupuser(name, email, pwd, store_op)
    FROM '/populate/clupuser.csv'
    DELIMITER ';'
    CSV HEADER;
COPY store(shop_name, chain_name, country, city, address,latitude, longitude, total_capacity, reserved_capacity)
    FROM '/populate/store.csv'
    DELIMITER ';'
    CSV HEADER;
COMMIT;
