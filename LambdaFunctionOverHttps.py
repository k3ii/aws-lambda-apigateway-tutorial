import boto3
from decimal import Decimal
import json

# Define the DynamoDB table
tableName = "lambda-apigateway"
# Create the DynamoDB resource
dynamo = boto3.resource('dynamodb').Table(tableName)

print('Loading function')

def handler(event, context):
    '''Provide an event that contains the following keys:
      - operation: one of the operations in the operations dict below
      - payload: a JSON object containing parameters to pass to the 
                 operation being performed
    '''
    
    # Attempt to parse the stringified 'body' from the event
    try:
        body = json.loads(event.get('body', '{}'))
    except json.JSONDecodeError:
        print("Body parsing failed")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': "Could not decode the request body"})
        }
    
    # Extract 'operation' and 'payload' from the parsed body
    operation = body.get('operation')
    payload = body.get('payload')
    
    if not operation or not payload:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': "Missing 'operation' or 'payload' keys"})
        }

    # Define the functions used to perform the CRUD operations
    def ddb_create(x):
        response = dynamo.put_item(**x)
        return {'message': 'Item created successfully', 'id': x['Item']['id']}

    def ddb_read(x):
        response = dynamo.get_item(**x)
        item = response.get('Item', {})
        
        # Convert all Decimal values to int or float
        for key, value in item.items():
            if isinstance(value, Decimal):
                item[key] = int(value) if value % 1 == 0 else float(value)
        
        return {'item': item}

    def ddb_update(x):
        response = dynamo.update_item(**x)
        return {'message': 'Item updated successfully'}

    def ddb_delete(x):
        response = dynamo.delete_item(**x)
        return {'message': 'Item deleted successfully'}

    def echo(x):
        return {'echo': x}

    operations = {
        'create': ddb_create,
        'read': ddb_read,
        'update': ddb_update,
        'delete': ddb_delete,
        'echo': echo,
    }

    if operation in operations:
        try:
            result = operations[operation](payload)
            return {
                'statusCode': 200,
                'body': json.dumps(result)
            }
        except Exception as e:
            print("Operation failed:", str(e))
            return {
                'statusCode': 500,
                'body': json.dumps({'error': str(e)})
            }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': f'Unrecognized operation "{operation}"'})
        }

