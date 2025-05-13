import boto3
import requests
import os
import json
from requests.auth import HTTPBasicAuth

def lambda_handler(event, context):
    # Fetch OpenSky credentials
    secrets_manager = boto3.client("secretsmanager")
    secret_name = os.environ["SECRET_NAME"]
    secret_value = secrets_manager.get_secret_value(SecretId=secret_name)
    credentials = json.loads(secret_value["SecretString"])
    
    username = credentials["username"]
    password = credentials["password"]

    # Fetch flight data
    response = requests.get(
        "https://opensky-network.org/api/states/all",
        auth=HTTPBasicAuth(username, password)
    )
    flights = response.json().get("states", [])

    # Filter for KQ flights near JKIA
    jkia_bounding_box = [33.5, 42.0, -5.0, 5.0]  # Rough East Africa box
    kq_flights = [
        flight for flight in flights 
        if flight[1].startswith("KQ") and 
        jkia_bounding_box[0] <= flight[5] <= jkia_bounding_box[1] and 
        jkia_bounding_box[2] <= flight[6] <= jkia_bounding_box[3]
    ]

    # Send notifications for each flight
    sns_client = boto3.client('sns')
    for flight in kq_flights:
        message = f"Flight {flight[1]} is approaching JKIA. Current coordinates: ({flight[5]}, {flight[6]})"
        sns_client.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=message,
            Subject="KQ Flight Approaching JKIA"
        )

    return {"statusCode": 200, "body": "Notifications sent"}
