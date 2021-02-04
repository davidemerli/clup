import json
import random


TOWN_PERCENTAGE = 3


def make_store(city, latitude, longitude):
    street_type = [
        "Corso",
        "Passeggiata",
        "Largo",
        "Piazza",
        "Piazzale",
        "Vicolo",
        "Bastioni",
        "Largo",
        "Parco",
    ] + ["Via"] * 3
    chains = [
        "Zetabreve",
        "Little",
        "Generali Alimentari",
        "Super",
        "Megamercato",
        "Eurostore",
        "Wallmars",
        "Ubersmart",
        "Copp",
        "Ikao",
        "O scian",
        "Cartfull",
    ]
    street_name = [
        "Roma",
        "Milano",
        "Garibaldi",
        "Vespucci",
        "Palermo",
        "Napoli",
        "Socrate",
        "Washington",
        "Bologna",
        "Salerno",
        "Fucini",
        "Leonardo da Vinci",
        "Umberto II",
        "Napoleone",
        "Giovanni da Procida",
        "Cervo",
        "R. Wagner",
        "Matteotti",
        "Gran Sasso",
        "Vesuvio",
    ]

    chain = random.choice(chains)
    store = {}
    store["store_name"] = f"{chain} di {city}"
    store["chain_name"] = chain
    store["country"] = "Italy"
    store["city"] = city
    store[
        "address"
    ] = f"{random.choice(street_type)} {random.choice(street_name)} {random.randrange(1,178)} "
    store["latitude"] = latitude
    store["longitude"] = longitude
    store["total_capacity"] = random.randrange(50, 250)
    store["reserved_capacity"] = store["total_capacity"] - random.randrange(5, 49)
    return store


def make_user(email, role="USER", store_id=None):
    name = [
        "Marco",
        "Luca",
        "Giovanni",
        "Giovanna",
        "Adriano",
        "Matteo",
        "Dario",
        "Davide",
        "Sara",
    ]
    surname = ["Rossi", "Verdi", "Bianchi"]
    user = {}
    user["name"] = f"{random.choice(name)} {random.choice(surname)}"
    user["email"] = email
    user["password"] = f"{email}"
    user["clup_role"] = role
    user["store_id"] = store_id
    return user


with open("comuni.json", "r") as f:
    towns = json.loads(f.read())

stores = []
users = []
store_id = 0
attendant_id = 0

for town in towns:
    if random.randrange(1, 100) > 100 - TOWN_PERCENTAGE:
        store_id += 1
        attendant_id += 1
        name = town["comune"]
        lng = town["lng"]
        lat = town["lat"]
        stores.append(make_store(name, lat, lng))
        users.append(
            make_user(
                f"operator{attendant_id}@CLup.com", role="OPERATOR", store_id=store_id
            )
        )

N_CUSTOMER = 100
for i in range(1, N_CUSTOMER):
    users.append(make_user(f"customer{i}@clup.com"))

output = {"stores": stores, "users": users}

with open("data.json", "w") as f:
    f.write(json.dumps(output, indent=2))
