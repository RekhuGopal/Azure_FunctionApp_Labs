import azure.functions as func
import logging
from azure.data.tables import TableServiceClient , UpdateMode

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="demofunctionazure")
def demofunctionazure(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    try:
        operationType = req.params.get('operationType')
    except Exception as e:
        operationType = None 
    try:
        name = req.params.get('name')
    except Exception as e:
        name = None 
    try:
        email = req.params.get('email')
    except Exception as e:
        email = None 
    try:
        phone = req.params.get('phone')
    except Exception as e:
        phone = None 
    try:
        city = req.params.get('city')
    except Exception as e:
        city = None 
    try:
        country = req.params.get('country')
    except Exception as e:
        country = None 
    '''
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')
    '''
    if operationType:
        connection_string = "DefaultEndpointsProtocol=https;AccountName=cloudquicklabsfatble;AccountKey=hsoqgs39O9b49D3OvLuop3ent8Rl0gL8WA5qv6QiXDKlIZFmleF+4qO7tsp2Gwq2FD/YMnvHzp9y+AStztCKIQ==;EndpointSuffix=core.windows.net"
        print(f"connection_string: {connection_string}")
        # table operations
        table_name = "employeerecords"
        service_client = TableServiceClient.from_connection_string(connection_string)

        #create a table 
        try:
            # Create the table if it does not already exist
            tc = service_client.create_table_if_not_exists(table_name)
            print(f"Hello, Table {table_name}has been created succesfully .")
        except Exception as e:
            print(f"An exception occured {e}")

        '''
        #delete a table 
        try:
            # Create the table if it does not already exist
            tc = service_client.delete_table(table_name)
            print(f"Hello, Table {table_name}has been deleted succesfully .")
        except Exception as e:
            print(f"An exception occured {e}")
        '''
        
        if operationType == "create":
            #define the table client from the table service client
            table_client = service_client.get_table_client(table_name=table_name)
            #create the data 
            my_entity = {
                u'name': name,
                u'PartitionKey': email,
                u'RowKey': phone,
                u'city': city,    
                u'country': country
            }
            try:
                entity = table_client.create_entity(entity=my_entity)
                print(f"Printing entity created {entity}")
                message = "create success"
            except Exception as e:
                print(f"An exception occured {e}")
                message = "An exception occured while creating the entity"

        if operationType == "update":
            #update the data
            my_entity_to_be_updated = {
                u'name': name,
                u'PartitionKey': email,
                u'RowKey': phone,
                u'city': city,    
                u'country': country
            }
            try:
                updatedentity = table_client.update_entity(mode=UpdateMode.MERGE, entity=my_entity_to_be_updated)
                print(f"Printing entity updated {entity}")
                message = "update success"
            except Exception as e:
                print(f"An exception occured {e}")
                message = "An exception occured while updating the entity"

        if operationType == "delete":
            #delete the data
            partitionkey = email
            rowkey = phone
            try:
                # delete the entity
                table_client.delete_entity(partitionkey, rowkey)
                print (f"Entry deleted succesfully")
                message = "delete success"
            except Exception as e:
                message = "An exception occured while deleting the entity"
                print(f"An exception occured {e}")

        return func.HttpResponse(f"operationType:{operationType} request processed and result is: {message}")
    else:
        return func.HttpResponse(f"operationType missing hence request failed")