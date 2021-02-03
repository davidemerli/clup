from . import api
from .auth_manager import Register, Login, Refresh, AccountStatus
from .information_provider import NearbyStores, StoreInfo
from .ticket_manager import CreateTicket, CancelTicket, GetActiveTicket
from .queue_manager import CallFirstTicket, AcceptTicket, CountStoreLeave


api.add_resource(Register, '/register')
api.add_resource(Login, '/login')
api.add_resource(NearbyStores, '/nearby_stores')
api.add_resource(CreateTicket, '/create_ticket')
api.add_resource(Refresh, '/refresh')
api.add_resource(AccountStatus, '/account_status')
api.add_resource(GetActiveTicket, '/active_ticket')
api.add_resource(CancelTicket, '/cancel_ticket')
api.add_resource(CallFirstTicket, '/call_first')
api.add_resource(AcceptTicket, '/accept_ticket')
api.add_resource(CountStoreLeave, '/count_store_leave')
api.add_resource(StoreInfo, '/store_info')