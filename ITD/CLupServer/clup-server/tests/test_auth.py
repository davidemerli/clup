from tests.test_fixtures import *

class TestAuthentication:
    @pytest.fixture(scope='session')
    def account(self, populate, flask_client):
        email = 'test@clup.com'
        password = '@1Aasfjakdjjd'
        reg_payload = dict(name='Test Account', email=email, password=password)
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert response.json['success']

        return {'email': email, 'password': password}
    
    
    def test_register(self, populate, flask_client):
        reg_payload = dict(name='John Doe', email='John@Doe.com', password='@1Aasfjakdjjd')
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert response.json['success']
        # Repeated
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert not response.json['success']

        # Not Valid Email
        reg_payload = dict(name='John Doe', email='JohnDoe.com', password='@1Aasfjakdjjd')
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'email' in response.json['errors']

        # Password
        reg_payload = dict(name='John Doe', email='John2@Doe.com', password='@1234provae')
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'password' in response.json['errors']

        # Missing Name
        reg_payload = dict(email='John2@Doe.com', password='@1234provae')
        response = post_json(flask_client, '/register', reg_payload)
        print(response.json)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'name' in response.json['errors']

    def test_login(self, flask_client, account):
        # Wrong Password test
        wrong_password = dict(email=account['email'], password=account['password'] + 'e')
        response = post_json(flask_client, '/login', wrong_password)
        assert response.status_code == 200
        assert not response.json['success']
        assert 'access_token' not in response.json
        assert 'refresh_token' not in response.json

        # Login Success
        response = post_json(flask_client, '/login', account)

        assert response.status_code == 200
        assert response.json['success']
        assert 'access_token' in response.json
        assert 'refresh_token' in response.json

        access_token = response.json['access_token']
        refresh_token = response.json['refresh_token']

        # Token Works
        response = post_json(flask_client, '/account_status', {}, bearer=access_token)
        assert response.status_code == 200
        assert response.json['success']

        # Refresh Works
        response = post_json(flask_client, '/refresh', {}, bearer=refresh_token)
        assert response.status_code == 200
        assert response.json['success']
        assert 'access_token' in response.json

        access_token = response.json['access_token']
        
        # Refreshed Token Works
        response = post_json(flask_client, '/account_status', {}, bearer=access_token)
        assert response.status_code == 200
        assert response.json['success']

