from tests.test_fixtures import *

class TestTicket:

    def test_double_create(self, flask_client, populate):
        auth, _ = login(flask_client, 'customer70@CLup.com', 'customer70@CLup.com')

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

        #Ticket cancellation
        response = post_json(flask_client, '/cancel_ticket', {},bearer=auth)
        assert response.status_code == 200
        assert response.json['success']

        # Second ticket creation succeed
        response = post_json(flask_client, '/create_ticket', {'store_id': 2}, bearer=auth)
        assert response.status_code == 200
        assert response.json['success']
        assert 'ticket' in response.json


    def test_queue_evolution(self, flask_client, populate):
        N_TESTERS = 50
        N_TICKETS = 10
        tokens = {i : login(flask_client, f'customer{i}@CLup.com', f'customer{i}@CLup.com')[0] for i in range(1,N_TESTERS)}
        operator_token = login(flask_client, f'operator1@CLup.com', f'operator1@CLup.com')[0]
        # LogIn All
        for i in range(1,11):            
            response = post_json(flask_client, '/create_ticket', {'store_id': 1}, bearer=tokens[i])

            print(f'User {i} queued in line')
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']
            ticket = response.json['ticket']
            assert ticket['line_position'] == i
        
        for i in range(1,11,2):
            response = post_json(flask_client, '/cancel_ticket', {}, bearer=tokens[i])

            print(f'User {i} cancelled ticket')

            assert response.status_code == 200
            assert response.json['success']

            response = post_json(flask_client, '/active_ticket', {}, bearer=tokens[i])

            assert response.status_code == 200
            assert response.json['success']
            assert response.json['ticket'] is None

        
        for i in range(2,11,2):
            response = post_json(flask_client, '/active_ticket', {}, bearer=tokens[i])

            assert response.status_code == 200
            assert response.json['success']
            ticket = response.json['ticket']
            assert ticket['line_position'] == int(i / 2)

        
        for _ in range(3):
            response = post_json(flask_client, '/call_first', {}, bearer=operator_token)
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']
        
        for pos, i in enumerate(range(8,11,2)):
            response = post_json(flask_client, '/active_ticket', {}, bearer=tokens[i])

            assert response.status_code == 200
            assert response.json['success']
            ticket = response.json['ticket']
            assert ticket['line_position'] == pos + 1

        
        for real_time_capacity, i in enumerate(range(2,7,2)):
            response = post_json(flask_client, '/accept_ticket', {'ticket_id': i + 1}, bearer=operator_token)
            print(f'Scanning ticket {i}')
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']

            response = post_json(flask_client, '/store_info', {'store_id': 1}, bearer=operator_token)
            assert response.status_code == 200
            assert response.json['success']
            store = response.json['store']
            print(store)
            assert store['real_time_capacity'] == real_time_capacity + 1


        response = post_json(flask_client, '/accept_ticket', {'ticket_id': 10}, bearer=operator_token)
        assert response.status_code == 200
        assert not response.json['success']
        

        for real_time_capacity in range(2, -1, -1):
            response = post_json(flask_client, '/count_store_leave', {}, bearer=operator_token)
            print(response.json)
            assert response.status_code == 200
            assert response.json['success']

        response = post_json(flask_client, '/count_store_leave', {}, bearer=operator_token)
        assert response.status_code == 200
        assert not response.json['success']

