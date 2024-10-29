import json
import datetime

def lambda_handler(event, context):
  current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

  return {
    'statusCode': 200,
    "headers": {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
    },
    'body': json.dumps({
      'message': 'lambda response',
      'timestamp': current_time
    })
  }