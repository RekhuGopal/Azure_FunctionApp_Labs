import os
from azure.data.tables import TableServiceClient , UpdateMode

connection_string = "<Staorage account connection string>"
print(f"connection_string: {connection_string}")

# table operations
table_name = "mydemotable"
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

#define the table client from the table service client
table_client = service_client.get_table_client(table_name=table_name)

#create the data 
my_entity = {
    u'PartitionKey': 'Germany',
    u'RowKey': 'Berlin',
    u'Landmark': 'Berlin Wall',
    u'Type': 'Historical Monument',    
    u'Status': True
}
try:
    entity = table_client.create_entity(entity=my_entity)
    print(f"Printing entity created {entity}")

except Exception as e:
    print(f"An exception occured {e}")



#update the data
my_entity_to_be_updated = {
    u'PartitionKey': 'Germany',
    u'RowKey': 'Berlin',
    u'Landmark': 'Berlin Wall',
    u'Relevance': 'World War II',
    u'Type': 'Historical Monument',    
    u'Status': True
}
try:
    updatedentity = table_client.update_entity(
        mode=UpdateMode.MERGE, entity=my_entity_to_be_updated)
    
    print(f"Printing entity updated {entity}")

except Exception as e:
    print(f"An exception occured {e}")


#delete the data
table_name = "mydemotable"
partitionkey = 'Germany'
rowkey = 'Berlin'

'''
try:
    # delete the entity
    table_client.delete_entity(partitionkey, rowkey)
    print (f"Entry deleted succesfully")

except Exception as e:
    print(f"An exception occured {e}")
'''