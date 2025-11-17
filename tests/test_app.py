"""
Unit tests for Flask application
Tests all endpoints and basic functionality
"""

import sys
import os

# Add parent directory to path to import app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../app')))

import pytest
from app import app


@pytest.fixture
def client():
    """
    Create a test client for the Flask app
    """
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_home_endpoint(client):
    """
    Test the home endpoint returns correct response
    """
    response = client.get('/')
    assert response.status_code == 200
    
    json_data = response.get_json()
    assert json_data['message'] == 'Welcome to Flask GitOps App!'
    assert json_data['status'] == 'running'
    assert 'version' in json_data


def test_health_endpoint(client):
    """
    Test the health check endpoint
    """
    response = client.get('/health')
    assert response.status_code == 200
    
    json_data = response.get_json()
    assert json_data['status'] == 'healthy'
    assert 'timestamp' in json_data
    assert 'version' in json_data


def test_ready_endpoint(client):
    """
    Test the readiness check endpoint
    """
    response = client.get('/ready')
    assert response.status_code == 200
    
    json_data = response.get_json()
    assert json_data['status'] == 'ready'
    assert 'timestamp' in json_data


def test_info_endpoint(client):
    """
    Test the info endpoint returns application details
    """
    response = client.get('/info')
    assert response.status_code == 200
    
    json_data = response.get_json()
    assert json_data['app_name'] == 'Flask GitOps Demo'
    assert 'version' in json_data
    assert 'endpoints' in json_data
    assert isinstance(json_data['endpoints'], list)
    assert len(json_data['endpoints']) > 0


def test_api_data_get(client):
    """
    Test GET request to /api/data endpoint
    """
    response = client.get('/api/data')
    assert response.status_code == 200
    
    json_data = response.get_json()
    assert 'data' in json_data
    assert 'count' in json_data
    assert json_data['count'] == 3


def test_api_data_post(client):
    """
    Test POST request to /api/data endpoint
    """
    test_data = {'test': 'value', 'number': 42}
    response = client.post('/api/data', json=test_data)
    assert response.status_code == 201
    
    json_data = response.get_json()
    assert json_data['message'] == 'Data received successfully'
    assert json_data['received_data'] == test_data


def test_404_error(client):
    """
    Test 404 error handler
    """
    response = client.get('/nonexistent')
    assert response.status_code == 404
    
    json_data = response.get_json()
    assert json_data['error'] == 'Not Found'
    assert json_data['status'] == 404
