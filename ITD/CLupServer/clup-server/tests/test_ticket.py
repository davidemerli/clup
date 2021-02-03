from tests.test_fixtures import *
from recordclass import recordclass
from collections import OrderedDict

class TestTicket:

    def test_double_create(self, flask_client, populate):
        auth, _ = login(flask_client, 'customer70@CLup.com', 'customer70@CLup.com')
        operator, _ = login(flask_client, 'operator2@CLup.com','operator2@CLup.com')

        # First ticket creation
        response = post_json(flask_client, '/create_ticket', {'store_id': 2}, bearer=auth)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json

        ticket_id = response.json['ticket']['ticket_id']
        
        # Second ticket creation fails
        response = post_json(flask_client, '/create_ticket', {'store_id': 2}, bearer=auth)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'ticket' not in response.json

        # Second ticket creation in another store fails
        response = post_json(flask_client, '/create_ticket', {'store_id': 3}, bearer=auth)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'ticket' not in response.json

        #Get Active Ticket
        response = post_json(flask_client, '/active_ticket',{}, bearer=auth)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json
        assert response.json['ticket']['ticket_id'] == ticket_id

        #Get Ticket Info
        response = post_json(flask_client, '/ticket_info', {'ticket_id': ticket_id}, bearer=operator)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json
        assert response.json['ticket']['ticket_id'] == ticket_id

        #Ticket cancellation
        response = post_json(flask_client, '/cancel_ticket', {},bearer=auth)
        assert response.status_code == 200
        assert response.json['success']

        #Get Ticket Info
        response = post_json(flask_client, '/ticket_info', {'ticket_id': ticket_id}, bearer=operator)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json
        assert response.json['ticket']['cancelled_on'] is not None
        assert response.json['ticket']['ticket_id'] == ticket_id

        # Second ticket creation succeed
        response = post_json(flask_client, '/create_ticket', {'store_id': 2}, bearer=auth)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json


    def test_queue_evolution(self, flask_client, populate):
        N_TICKETS = 10
        operator_token = login(flask_client, f'operator1@CLup.com', f'operator1@CLup.com')[0]
        ClientInfo = recordclass('ClientInfo', 'token ticket_id status')
        # LogIn All
        clients = OrderedDict()

        for i in range(1, N_TICKETS):
            token = login(flask_client, f'customer{i}@CLup.com', f'customer{i}@CLup.com')[0]
            clients[i] = ClientInfo(token, None, None)
        
        # Enqueue N_TICKETS User in the same store
        for i in range(1,N_TICKETS):            
            response = post_json(flask_client, '/create_ticket', {'store_id': 1}, bearer=clients[i].token)

            print(f'User {i} queued in line')
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']
            ticket = response.json['ticket']
            assert ticket['line_position'] == i
            clients[i].ticket_id = ticket['ticket_id']
            clients[i].status = Ticket.STATE_ISSUED

        # Cancel Half of the tickets in line
        for i in range(1,11,2):
            # Cancel ticket
            response = post_json(flask_client, '/cancel_ticket', {}, bearer=clients[i].token)

            print(f'User {i} cancelled ticket')

            assert response.status_code == 200
            assert response.json['success']

            # Check correct ticket removal
            response = post_json(flask_client, '/active_ticket', {}, bearer=clients[i].token)

            assert response.status_code == 200
            assert response.json['success']
            assert response.json['ticket'] is None
            clients[i].status = Ticket.STATE_CANCELLED

        # Check that position in line is updated correctly
        position = 1
        for i, info in clients.items():
            if info.status == Ticket.STATE_ISSUED:
                response = post_json(flask_client, '/active_ticket', {}, bearer=info.token)
                assert response.status_code == 200
                assert response.json['success']
                ticket = response.json['ticket']
                assert ticket['line_position'] == position
                position += 1

        N_CALLS = 3
        # Call N_CALLS tickets
        for i in range(N_CALLS):
            response = post_json(flask_client, '/call_first', {}, bearer=operator_token)
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']

        # Update local ticket status
        called = [i for i, info in clients.items() if info.status == Ticket.STATE_ISSUED][:N_CALLS]        
        for i in called:
            clients[i].status = Ticket.STATE_CALLED

        position = 1
        # Check if ticket is active
        for i, info in clients.items():
            if info.status == Ticket.STATE_ISSUED:
                response = post_json(flask_client, '/active_ticket', {}, bearer=info.token)

                assert response.status_code == 200
                assert response.json['success']
                ticket = response.json['ticket']
                assert ticket['line_position'] == position
                position += 1
        
        response = post_json(flask_client, '/queue_status', {}, bearer=operator_token)
        
        assert response.status_code == 200
        assert response.json['success']
        queued_tickets = response.json['queue_ticket_ids']
        print(f'Queue Status {queued_tickets}')
        print(response.json)
        assert queued_tickets == [info.ticket_id for info in clients.values() if info.status == Ticket.STATE_ISSUED]



        # Accept ticket in the store
        capacity = 0       
        for i, info in clients.items():
            if info.status == Ticket.STATE_CALLED:
                # Check if the respose is correct
                response = post_json(flask_client, '/accept_ticket', {'ticket_id': info.ticket_id}, bearer=operator_token)
                print(f'Scanning ticket {i}')
                assert response.status_code == 200
                assert response.json['success']

                capacity += 1
                # Check if real_time_capacity of the store is correct
                response = post_json(flask_client, '/store_info', {'store_id': 1}, bearer=operator_token)
                assert response.status_code == 200
                assert response.json['success']
                store = response.json['store']
                assert store['real_time_capacity'] == capacity
            else:
                # Check if the entry to the store is refused to non-called tickets
                response = post_json(flask_client, '/accept_ticket', {'ticket_id': 10}, bearer=operator_token)
                assert response.status_code == 200
                assert not response.json['success']
        
        # Let N_CALLS customer leave the store
        for real_time_capacity in range(N_CALLS - 1, -1, -1):
            response = post_json(flask_client, '/count_store_leave', {}, bearer=operator_token)
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']
        # If the store is empty this operation is not permitted
        response = post_json(flask_client, '/count_store_leave', {}, bearer=operator_token)
        assert response.status_code == 200
        assert not response.json['success']
    
    

