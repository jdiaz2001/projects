import json
import os
import boto3
import socket

# Set up SNS client
sns_client = boto3.client('sns')

# Retrieve the SNS topic ARN from environment variables
topic_arn = os.environ['SNS_TOPIC_ARN']

def is_server_reachable(server, port=80, timeout=2):
    """Check if the server is reachable via TCP."""
    try:
        with socket.create_connection((server, port), timeout) as sock:
            return True
    except (socket.timeout, socket.error) as e:
        print(f"Connection error for {server}: {e}")
        return False

def lambda_handler(event, context):
    servers = ['store.mynsm.uh.edu', '52.22.51.49']  # Replace with your servers
    for server in servers:
        if is_server_reachable(server):
            message = f"Server {server} is reachable."
            print(message)
        else:
            message = f"Server {server} is unreachable."
            print(message)
            # Publish to SNS
            sns_client.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject='Server Unreachable Alert'
            )

    return {
        'statusCode': 200,
        'body': json.dumps('Ping operation completed.')
    }
