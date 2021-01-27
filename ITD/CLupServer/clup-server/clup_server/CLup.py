from auth_manager import Register, Login
from information_provider import NearbyStores
from ticket_manager import CreateTicket
from config import app, api

api.add_resource(Register, '/register')
api.add_resource(Login, '/login')
api.add_resource(NearbyStores, '/nearby_stores')
api.add_resource(CreateTicket, '/create_ticket')

if __name__ == '__main__':
    # TODO: Remove this in production
    app.config["DEBUG"] = True
    app.run()
