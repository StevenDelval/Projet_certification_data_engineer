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
  name                = "AzureDataLakeStorage"
  data_factory_id     = azurerm_data_factory.data_factory.id

  storage_account_key = azurerm_storage_account.data_lake.primary_access_key
  url = "https://${azurerm_storage_account.data_lake.name}.dfs.core.windows.net/"

}


resource "azurerm_data_factory_linked_custom_service" "postgres_ls" {
name              = "AzurePostgreSql"
  data_factory_id   = azurerm_data_factory.data_factory.id

  type                 = "AzurePostgreSql"
  
  type_properties_json = <<JSON
{
  "connectionString":"host=${azurerm_postgresql_flexible_server.postgres_server.fqdn};port=5432;database=${azurerm_postgresql_flexible_server_database.db_data.name};uid=${var.admin_login};encryptionmethod=1;validateservercertificate=1;password=${var.admin_password}"
}
JSON
}


resource "azurerm_data_factory_custom_dataset" "table_meteo" {
  name                = "TableMeteo"
  data_factory_id     = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name
    
  }

  type_properties_json = <<JSON
  {
            "schema": "public",
            "table": "TableMeteoQuotidien"
        }
JSON
  schema_json = <<JSON
  [
            {
                "name": "LAMBX",
                "type": "bigint",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "LAMBY",
                "type": "bigint",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "DATE",
                "type": "text",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "PRENEI_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "PRELIQ_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "T_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "FF_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "Q_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "DLI_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "SSI_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "HU_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "EVAP_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "ETP_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "PE_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "SWI_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "DRAINC_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "RUNC_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "RESR_NEIGE_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "RESR_NEIGE6_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "HTEURNEIGE_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "HTEURNEIGE6_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "HTEURNEIGEX_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "SNOW_FRAC_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "ECOULEMENT_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "WG_RACINE_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "WGI_RACINE_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "TINF_H_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            },
            {
                "name": "TSUP_H_Q",
                "type": "double precision",
                "precision": 0,
                "scale": 0
            }
        ]
JSON

}

resource "azurerm_data_factory_dataset_parquet" "parquet_data_weather" {
  name                = "Parquet_data_weather"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake_ls.name

  azure_blob_fs_location {
    file_system = "donnees-meteo"
    path = "quotidien"
  }
  compression_codec = "snappy"
}

resource "azurerm_data_factory_dataset_parquet" "parquet_file_piezo" {
  name                = "Parquet_file_piezo"
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


resource "azurerm_data_factory_data_flow" "copy_data_weather" {
  name            = "copy_data_weather"
  data_factory_id = azurerm_data_factory.data_factory.id

  source {
    name = "sourceparquetdataweather"


    dataset {
      name = azurerm_data_factory_dataset_parquet.parquet_data_weather.name
    }
  }

  sink {
    name = "postgreTableMeteoQuotidien"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_meteo.name
    }
  }

  script = <<EOT
    source(
    output(
        LAMBX as long,
        LAMBY as long,
        DATE as string,
        PRENEI_Q as double,
        PRELIQ_Q as double,
        T_Q as double,
        FF_Q as double,
        Q_Q as double,
        DLI_Q as double,
        SSI_Q as double,
        HU_Q as double,
        EVAP_Q as double,
        ETP_Q as double,
        PE_Q as double,
        SWI_Q as double,
        DRAINC_Q as double,
        RUNC_Q as double,
        RESR_NEIGE_Q as double,
        RESR_NEIGE6_Q as double,
        HTEURNEIGE_Q as double,
        HTEURNEIGE6_Q as double,
        HTEURNEIGEX_Q as double,
        SNOW_FRAC_Q as double,
        ECOULEMENT_Q as double,
        WG_RACINE_Q as double,
        WGI_RACINE_Q as double,
        TINF_H_Q as double,
        TSUP_H_Q as double
    ),
    allowSchemaDrift: true,
    validateSchema: false,
    ignoreNoFilesFound: false,
    format: 'parquet'
) ~> sourceparquetdataweather

sourceparquetdataweather sink(
    allowSchemaDrift: true,
    validateSchema: false,
    input(
        LAMBX as long,
        LAMBY as long,
        DATE as string,
        PRENEI_Q as double,
        PRELIQ_Q as double,
        T_Q as double,
        FF_Q as double,
        Q_Q as double,
        DLI_Q as double,
        SSI_Q as double,
        HU_Q as double,
        EVAP_Q as double,
        ETP_Q as double,
        PE_Q as double,
        SWI_Q as double,
        DRAINC_Q as double,
        RUNC_Q as double,
        RESR_NEIGE_Q as double,
        RESR_NEIGE6_Q as double,
        HTEURNEIGE_Q as double,
        HTEURNEIGE6_Q as double,
        HTEURNEIGEX_Q as double,
        SNOW_FRAC_Q as double,
        ECOULEMENT_Q as double,
        WG_RACINE_Q as double,
        WGI_RACINE_Q as double,
        TINF_H_Q as double,
        TSUP_H_Q as double
    ),
    deletable: false,
    insertable: true,
    updateable: false,
    upsertable: false,
    truncate: true,
    format: 'table',
    skipDuplicateMapInputs: true,
    skipDuplicateMapOutputs: true
) ~> postgreTableMeteoQuotidien
    EOT
}


resource "azurerm_data_factory_pipeline" "pipeline_copy_data_in_db" {
  name                    = "copy_data_in_db"
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
            "referenceName": "${azurerm_data_factory_data_flow.copy_data_weather.name}",
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
