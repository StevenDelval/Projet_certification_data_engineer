resource "azurerm_data_factory" "data_factory" {
  name                = "ADF-projet-SD"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_data_factory_linked_service_sql_server" "ct_database" {
  name                 = "control_database"
  data_factory_id = azurerm_data_factory.data_factory.id
  connection_string    = "Server=tcp:my-sqlserver-sd.database.windows.net;Database=databaseControlTables;User ID=Sdelval;Password=${var.admin_password};"
}

resource "azurerm_data_factory_linked_service_azure_function" "csv_function" {
  name                 = "Csv_function"
  data_factory_id = azurerm_data_factory.data_factory.id
  url     = "https://get-weather-data-projet-sd.azurewebsites.net"
  key = module.azure_functions_weather_data.function_key
}

resource "azurerm_data_factory_linked_service_azure_function" "api_function" {
  name                 = "Api_function"
  
  data_factory_id = azurerm_data_factory.data_factory.id
  url     = "https://get-hubeau-api-data-projet-sd.azurewebsites.net"
  key = module.azure_functions_api.function_key
}

resource "azurerm_data_factory_dataset_sql_server_table" "table_control_for_csv" {
  name                    = "Table_control_for_csv"
  data_factory_id = azurerm_data_factory.data_factory.id
  linked_service_name     = azurerm_data_factory_linked_service_sql_server.ct_database.name
  table_name              = "CsvControlTable"
}

resource "azurerm_data_factory_dataset_sql_server_table" "table_control_for_api" {
  name                    = "Table_control_for_api"
  data_factory_id = azurerm_data_factory.data_factory.id
  linked_service_name     = azurerm_data_factory_linked_service_sql_server.ct_database.name
  table_name              = "ApiControlTable"
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "datalake_ls" {
  name                = "AzureDataLakeStoragetest"
  data_factory_id     = azurerm_data_factory.data_factory.id

  storage_account_key = azurerm_storage_account.data_lake.primary_access_key
  url = "https://${azurerm_storage_account.data_lake.name}.dfs.core.windows.net/"

}

resource "azurerm_data_factory_linked_service_postgresql" "postgres_ls" {
  name              = "AzurePostgreSqltest"
  data_factory_id   = azurerm_data_factory.data_factory.id

  connection_string = "Host=${azurerm_postgresql_flexible_server.postgres_server.fqdn};Port=5432;Database=${azurerm_postgresql_flexible_server_database.db_data.name};UID=${var.admin_login};EncryptionMethod=1;Password=${var.admin_password}"
}

resource "azurerm_data_factory_dataset_postgresql" "table_meteo" {
  name                = "TableMeteotest"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_postgresql.postgres_ls.name

  table_name = "TableMeteoQuotidien"
}

resource "azurerm_data_factory_dataset_parquet" "parquet_data_weather" {
  name                = "Parquet_data_weather_test"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake_ls.name

  azure_blob_fs_location {
    file_system = "donnees-meteo"
    path = "quotidien"
  }
  compression_codec = "snappy"
}

resource "azurerm_data_factory_dataset_parquet" "parquet_file_piezo" {
  name                = "Parquet_file_piezo_test"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake_ls.name

  azure_blob_fs_location {
    file_system = "donnees-piezometre"
    path = "quotidien"
  }
  compression_codec = "snappy"
}


resource "azurerm_data_factory_pipeline" "pipeline_get_csv" {
  name                    = "pipeline_get_csv"
  data_factory_id = azurerm_data_factory.data_factory.id
  activities_json         = <<JSON
  [
      {
          "name": "get_info_csv",
          "type": "Lookup",
          "dependsOn": [],
          "policy": {
              "timeout": "0.12:00:00",
              "retry": 0,
              "retryIntervalInSeconds": 30,
              "secureOutput": false,
              "secureInput": false
          },
          "userProperties": [],
          "typeProperties": {
              "source": {
                  "type": "AzureSqlSource",
                  "sqlReaderQuery": "SELECT nom_du_fichier, url_du_fichier FROM CsvControlTable",
                  "queryTimeout": "02:00:00",
                  "partitionOption": "None"
              },
              "dataset": {
                  "referenceName": "${azurerm_data_factory_dataset_sql_server_table.table_control_for_csv.name}",
                  "type": "DatasetReference"
              },
              "firstRowOnly": false
          }
      },
      {
          "name": "ForEach1",
          "type": "ForEach",
          "dependsOn": [
              {
                  "activity": "get_info_csv",
                  "dependencyConditions": [
                      "Succeeded"
                  ]
              }
          ],
          "userProperties": [],
          "typeProperties": {
              "items": {
                  "value": "@activity('get_info_csv').output.value",
                  "type": "Expression"
              },
              "isSequential": false,
              "batchCount": 1,
              "activities": [
                  {
                      "name": "Azure Function Get csv",
                      "type": "AzureFunctionActivity",
                      "dependsOn": [],
                      "policy": {
                          "timeout": "0.12:00:00",
                          "retry": 0,
                          "retryIntervalInSeconds": 30,
                          "secureOutput": false,
                          "secureInput": false
                      },
                      "userProperties": [],
                      "typeProperties": {
                          "functionName": "${module.azure_functions_weather_data.endpoint}",
                          "body": {
                              "value": "{\n    \"file_name\":\"@{item().nom_du_fichier}\",\n    \"url_csv_file\":\"@{item().url_du_fichier}\"\n    }",
                              "type": "Expression"
                          },
                          "method": "POST"
                      },
                      "linkedServiceName": {
                          "referenceName": "${azurerm_data_factory_linked_service_azure_function.csv_function.name}",
                          "type": "LinkedServiceReference"
                      }
                  }
              ]
          }
      },
      {
          "name": "DeleteUselessRow",
          "type": "SqlServerStoredProcedure",
          "dependsOn": [
              {
                  "activity": "ForEach1",
                  "dependencyConditions": [
                      "Succeeded"
                  ]
              }
          ],
          "policy": {
              "timeout": "0.12:00:00",
              "retry": 0,
              "retryIntervalInSeconds": 30,
              "secureOutput": false,
              "secureInput": false
          },
          "userProperties": [],
          "typeProperties": {
              "storedProcedureName": "[dbo].[DeleteUselessRow]"
          },
          "linkedServiceName": {
              "referenceName": "${azurerm_data_factory_linked_service_sql_server.ct_database.name}",
              "type": "LinkedServiceReference"
          }
      }
  ]
  JSON
}

resource "azurerm_data_factory_pipeline" "pipeline_get_api" {
  name                    = "pipeline_get_api"
  data_factory_id = azurerm_data_factory.data_factory.id
  activities_json         = <<JSON
  [
      {
          "name": "get_info_api",
          "type": "Lookup",
          "dependsOn": [],
          "policy": {
              "timeout": "0.12:00:00",
              "retry": 0,
              "retryIntervalInSeconds": 30,
              "secureOutput": false,
              "secureInput": false
          },
          "userProperties": [],
          "typeProperties": {
              "source": {
                  "type": "AzureSqlSource",
                  "sqlReaderQuery": "SELECT code_bss, date_debut_mesure FROM ApiControlTable",
                  "queryTimeout": "02:00:00",
                  "partitionOption": "None"
              },
              "dataset": {
                  "referenceName": "${azurerm_data_factory_dataset_sql_server_table.table_control_for_api.name}",
                  "type": "DatasetReference"
              },
              "firstRowOnly": false
          }
      },
      {
          "name": "ForEach1",
          "type": "ForEach",
          "dependsOn": [
              {
                  "activity": "get_info_api",
                  "dependencyConditions": [
                      "Succeeded"
                  ]
              }
          ],
          "userProperties": [],
          "typeProperties": {
              "items": {
                  "value": "@activity('get_info_api').output.value",
                  "type": "Expression"
              },
              "isSequential": false,
              "batchCount": 1,
              "activities": [
                  {
                      "name": "Azure Function Get api",
                      "type": "AzureFunctionActivity",
                      "dependsOn": [],
                      "policy": {
                          "timeout": "0.12:00:00",
                          "retry": 0,
                          "retryIntervalInSeconds": 30,
                          "secureOutput": false,
                          "secureInput": false
                      },
                      "userProperties": [],
                      "typeProperties": {
                          "functionName": "${module.azure_functions_api.endpoint}",
                          "body": {
                              "value": "{\n    \"code_bss\":\"@{item().code_bss}\"   }",
                              "type": "Expression"
                          },
                          "method": "POST"
                      },
                      "linkedServiceName": {
                          "referenceName": "${azurerm_data_factory_linked_service_azure_function.api_function.name}",
                          "type": "LinkedServiceReference"
                      }
                  }
              ]
          }
      }
  ]
  JSON
}




resource "azurerm_data_factory_pipeline" "pipeline_copy_data_in_db" {
  name                    = "copy_data_in_db_test"
  data_factory_id = azurerm_data_factory.data_factory.id
  activities_json         = <<JSON
  [
    {
        "name": "Data flow copy data weather",
        "type": "ExecuteDataFlow",
        "dependsOn": [],
        "policy": {
            "timeout": "0.12:00:00",
            "retry": 0,
            "retryIntervalInSeconds": 30,
            "secureOutput": false,
            "secureInput": false
        },
        "userProperties": [],
        "typeProperties": {
            "dataflow": {
            "referenceName": "copy_data_weather",
            "type": "DataFlowReference"
            },
            "compute": {
            "coreCount": 8,
            "computeType": "General"
            },
            "traceLevel": "Fine"
        }
    }
  ]
  JSON
}
    
resource "azurerm_data_factory_trigger_schedule" "trigger_schedule" {
  name            = "trigger_schedule"
  data_factory_id = azurerm_data_factory.data_factory.id

  pipeline {
    name = azurerm_data_factory_pipeline.pipeline_get_api.name
  }
  pipeline {
    name = azurerm_data_factory_pipeline.pipeline_get_csv.name
  }
  frequency = "Month"
  interval  = 1
  start_time = "2025-04-08T10:00:00Z" 
  time_zone  = "Romance Standard Time"
  schedule {
      minutes   = [0]
      hours     = [10]
      days_of_month = [8]
    }
}
