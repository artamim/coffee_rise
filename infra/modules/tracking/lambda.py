import json
import os
import boto3
from datetime import datetime, timedelta, timezone

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        ip = event['requestContext']['http']['sourceIp']
        user_agent = event['requestContext']['http']['userAgent']
        timestamp = int(datetime.now(timezone.utc).timestamp())

        # Increment total counter
        counter_table = dynamodb.Table(os.environ['COUNTER_TABLE'])
        response = counter_table.update_item(
            Key={'id': 'total_visits'},
            UpdateExpression='ADD visit_count :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )
        total_visits = response['Attributes']['visit_count']

        # Log details with 7-day TTL
        logs_table = dynamodb.Table(os.environ['LOGS_TABLE'])
        ttl_expiry = int((datetime.now(timezone.utc) + timedelta(days=7)).timestamp())
        logs_table.put_item(
            Item={
                'id': f"{timestamp}-{ip}",
                'ip': ip,
                'user_agent': user_agent,
                'timestamp': timestamp,
                'ttl': ttl_expiry
            }
        )

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'total_visits': int(total_visits)})
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }