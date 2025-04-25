resource "azurerm_data_factory" "data_factory" {
  name                = "ADF-projet-SD"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_data_factory_linked_service_sql_server" "ct_database" {
  name              = "control_database"
  data_factory_id   = azurerm_data_factory.data_factory.id
  connection_string = "Server=tcp:my-sqlserver-sd.database.windows.net;Database=databaseControlTables;User ID=Sdelval;Password=${var.admin_password};"
}

resource "azurerm_data_factory_linked_service_azure_function" "csv_function" {
  name            = "Csv_function"
  data_factory_id = azurerm_data_factory.data_factory.id
  url             = "https://get-weather-data-projet-sd.azurewebsites.net"
  key             = module.azure_functions_weather_data.function_key
}

resource "azurerm_data_factory_linked_service_azure_function" "api_function" {
  name = "Api_function"

  data_factory_id = azurerm_data_factory.data_factory.id
  url             = "https://get-hubeau-api-data-projet-sd.azurewebsites.net"
  key             = module.azure_functions_api.function_key
}

resource "azurerm_data_factory_dataset_sql_server_table" "table_control_for_csv" {
  name                = "Table_control_for_csv"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.ct_database.name
  table_name          = "CsvControlTable"
  folder = "ControlTables"
}

resource "azurerm_data_factory_dataset_sql_server_table" "table_control_for_api" {
  name                = "Table_control_for_api"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.ct_database.name
  table_name          = "ApiControlTable"
  folder = "ControlTables"
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "datalake_ls" {
  name            = "AzureDataLakeStorage"
  data_factory_id = azurerm_data_factory.data_factory.id

  storage_account_key = azurerm_storage_account.data_lake.primary_access_key
  url                 = "https://${azurerm_storage_account.data_lake.name}.dfs.core.windows.net/"

}


resource "azurerm_data_factory_linked_custom_service" "postgres_ls" {
  name            = "AzurePostgreSql"
  data_factory_id = azurerm_data_factory.data_factory.id

  type = "AzurePostgreSql"

  type_properties_json = <<JSON
{
  "connectionString":"host=${azurerm_postgresql_flexible_server.postgres_server.fqdn};port=5432;database=${azurerm_postgresql_flexible_server_database.db_data.name};uid=${var.admin_login};encryptionmethod=1;validateservercertificate=1;password=${var.admin_password}"
}
JSON
}


resource "azurerm_data_factory_custom_dataset" "table_meteo_quotidien" {
  name            = "TableMeteoQuotidien"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "TableMeteoQuotidien"
    }
  JSON
  schema_json          = <<JSON
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

resource "azurerm_data_factory_custom_dataset" "table_piezo_quotidien" {
  name            = "TablePiezoQuotidien"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "TablePiezoQuotidien"
    }
  JSON
  schema_json          = <<JSON
   [
        {
            "name": "code_bss",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "date_mesure",
            "type": "date",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "code_nature_mesure",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "code_continuite",
            "type": "integer",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "code_producteur",
            "type": "bigint",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "qualification",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "statut",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "mode_obtention",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "profondeur_nappe",
            "type": "real",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "niveau_nappe_eau",
            "type": "real",
            "precision": 0,
            "scale": 0
        }
    ]
  JSON

}

resource "azurerm_data_factory_custom_dataset" "table_piezo_info" {
  name            = "TablePiezoInfo"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "TablePiezoInfo"
    }
  JSON
  schema_json          = <<JSON
   [
        {
            "name": "code_bss",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "urn_bss",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "LAMBX",
            "type": "integer",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "LAMBY",
            "type": "integer",
            "precision": 0,
            "scale": 0
        }
    ]
  JSON

}

resource "azurerm_data_factory_custom_dataset" "table_continuite" {
  name            = "Continuite"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "Continuite"
    }
  JSON
  schema_json          = <<JSON
   [
        {
            "name": "code_continuite",
            "type": "integer",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "nom_continuite",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        }
    ]
  JSON
}

resource "azurerm_data_factory_custom_dataset" "table_nature_mesure" {
  name            = "Nature_mesure"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "Nature_mesure"
    }
  JSON
  schema_json          = <<JSON
   [
        {
            "name": "code_nature_mesure",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "nom_nature_mesure",
            "type": "character varying",
            "precision": 0,
            "scale": 0
        }
    ]
  JSON

}

resource "azurerm_data_factory_custom_dataset" "table_producteur" {
  name            = "Producteur"
  data_factory_id = azurerm_data_factory.data_factory.id
  type            = "AzurePostgreSqlTable"
  folder = "PostgresTables"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.postgres_ls.name

  }

  type_properties_json = <<JSON
   {
        "schema": "public",
        "table": "Producteur"
    }
  JSON

  schema_json          = <<JSON
    [
        {
            "name": "code_producteur",
            "type": "bigint",
            "precision": 0,
            "scale": 0
        },
        {
            "name": "nom_producteur",
            "type": "character varying",
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
  folder = "ParquetFiles"

  azure_blob_fs_location {
    file_system = "donnees-meteo"
    path        = "quotidien"
  }
  compression_codec = "snappy"
}

resource "azurerm_data_factory_dataset_parquet" "parquet_file_piezo" {
  name                = "Parquet_file_piezo"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake_ls.name
  folder = "ParquetFiles"

  azure_blob_fs_location {
    file_system = "donnees-piezometre"
    path        = "quotidien"
  }
  compression_codec = "snappy"
}


resource "azurerm_data_factory_pipeline" "pipeline_get_csv" {
  name            = "pipeline_get_csv"
  data_factory_id = azurerm_data_factory.data_factory.id
  folder = "Extration"
  activities_json = <<JSON
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
  name            = "pipeline_get_api"
  data_factory_id = azurerm_data_factory.data_factory.id
  folder = "Extration"
  activities_json = <<JSON
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
      name = azurerm_data_factory_custom_dataset.table_meteo_quotidien.name
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

resource "azurerm_data_factory_data_flow" "copy_data_tables_infos" {
  name            = "copy_data_tables_infos"
  data_factory_id = azurerm_data_factory.data_factory.id

  source {
    name = "parquetfilepiezo"

    dataset {
      name = azurerm_data_factory_dataset_parquet.parquet_file_piezo.name
    }
  }

  sink {
    name = "toTablePiezoInfo"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_piezo_info.name
    }
  }
  sink {
    name = "toContinuite"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_continuite.name
    }
  }
  sink {
    name = "toProducteur"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_producteur.name
    }
  }
  sink {
    name = "toNaturemesure"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_nature_mesure.name
    }
  }

  script = <<EOT
   source(
    output(
            code_bss as string,
            urn_bss as string,
            date_mesure as string,
            niveau_nappe_eau as double,
            mode_obtention as string,
            statut as string,
            qualification as string,
            code_continuite as string,
            nom_continuite as string,
            code_producteur as string,
            nom_producteur as string,
            code_nature_mesure as string,
            nom_nature_mesure as string,
            profondeur_nappe as double
        ),
        allowSchemaDrift: true,
        validateSchema: false,
        ignoreNoFilesFound: false,
        format: 'parquet') ~> parquetfilepiezo
    parquetfilepiezo select(mapColumn(
            code_nature_mesure,
            nom_nature_mesure
        ),
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> selectfornaturemesure
    parquetfilepiezo select(mapColumn(
            code_producteur,
            nom_producteur
        ),
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> selectforproducteur
    parquetfilepiezo select(mapColumn(
            code_continuite,
            nom_continuite
        ),
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> selectforcontinuite
    parquetfilepiezo select(mapColumn(
            code_bss,
            urn_bss
        ),
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> selectcolforpiezoinfo
    distinctrowpiezoinfo alterRow(updateIf(true())) ~> alterRowpiezoinfo
    selectforcontinuite aggregate(groupBy(code_continuite,
            nom_continuite),
        each(patternMatch(`$$` , true()), $$ = first($$))) ~> distinctrowcontinuite
    selectforproducteur aggregate(groupBy(code_producteur,
            nom_producteur),
        each(patternMatch(`$$` , true()), $$ = first($$))) ~> distinctrowproducteur
    selectfornaturemesure aggregate(groupBy(code_nature_mesure,
            nom_nature_mesure),
        each(patternMatch(`$$` , true()), $$ = first($$))) ~> distinctrownaturemesure
    selectcolforpiezoinfo aggregate(groupBy(code_bss,
            urn_bss),
        each(patternMatch(`$$` , true()), $$ = first($$))) ~> distinctrowpiezoinfo
    distinctrowcontinuite alterRow(upsertIf(true())) ~> alterRowcontinuite
    distinctrowproducteur alterRow(upsertIf(true())) ~> alterRowproducteur
    distinctrownaturemesure alterRow(upsertIf(true())) ~> alterRownaturemesure
    alterRownaturemesure sink(allowSchemaDrift: true,
        validateSchema: false,
        input(
            code_nature_mesure as string,
            nom_nature_mesure as string
        ),
        deletable:false,
        insertable:false,
        updateable:false,
        upsertable:true,
        keys:['code_nature_mesure'],
        format: 'table',
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true,
        saveOrder: 1) ~> toNaturemesure
    alterRowproducteur sink(allowSchemaDrift: true,
        validateSchema: false,
        input(
            code_producteur as integer,
            nom_producteur as string
        ),
        deletable:false,
        insertable:false,
        updateable:false,
        upsertable:true,
        keys:['code_producteur'],
        format: 'table',
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true,
        saveOrder: 1) ~> toProducteur
    alterRowcontinuite sink(allowSchemaDrift: true,
        validateSchema: false,
        input(
            code_continuite as integer,
            nom_continuite as string
        ),
        deletable:false,
        insertable:false,
        updateable:false,
        upsertable:true,
        keys:['code_continuite'],
        format: 'table',
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true,
        saveOrder: 1) ~> toContinuite
    alterRowpiezoinfo sink(allowSchemaDrift: true,
        validateSchema: false,
        input(
            code_bss as string,
            urn_bss as string,
            LAMBX as integer,
            LAMBY as integer
        ),
        deletable:false,
        insertable:false,
        updateable:true,
        upsertable:false,
        keys:['code_bss'],
        format: 'table',
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> toTablePiezoInfo
  EOT
}

resource "azurerm_data_factory_data_flow" "copy_data_table_piezo_quotidien" {
  name            = "copy_data_table_piezo_quotidien"
  data_factory_id = azurerm_data_factory.data_factory.id

  source {
    name = "parquetfilepiezo"

    dataset {
      name = azurerm_data_factory_dataset_parquet.parquet_file_piezo.name
    }
  }

  sink {
    name = "toTablePiezoQuotidien"

    dataset {
      name = azurerm_data_factory_custom_dataset.table_piezo_quotidien.name
    }
  }
  script = <<EOT
    source(
        output(
            code_bss as string,
            urn_bss as string,
            date_mesure as string,
            niveau_nappe_eau as double,
            mode_obtention as string,
            statut as string,
            qualification as string,
            code_continuite as string,
            nom_continuite as string,
            code_producteur as string,
            nom_producteur as string,
            code_nature_mesure as string,
            nom_nature_mesure as string,
            profondeur_nappe as double
        ),
        allowSchemaDrift: true,
        validateSchema: false,
        ignoreNoFilesFound: false,
        format: 'parquet') ~> parquetfilepiezo
    parquetfilepiezo select(mapColumn(
            code_bss,
            date_mesure,
            niveau_nappe_eau,
            mode_obtention,
            statut,
            qualification,
            code_continuite,
            code_producteur,
            code_nature_mesure,
            profondeur_nappe
        ),
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> selectpiezoquotidien
    selectpiezoquotidien alterRow(upsertIf(true())) ~> alterRow1piezoquotidien
    alterRow1piezoquotidien sink(allowSchemaDrift: true,
        validateSchema: false,
        input(
            code_bss as string,
            date_mesure as date,
            code_nature_mesure as string,
            code_continuite as integer,
            code_producteur as long,
            qualification as string,
            statut as string,
            mode_obtention as string,
            profondeur_nappe as float,
            niveau_nappe_eau as float
        ),
        deletable:false,
        insertable:false,
        updateable:false,
        upsertable:true,
        keys:['code_bss','date_mesure'],
        format: 'table',
        skipDuplicateMapInputs: true,
        skipDuplicateMapOutputs: true) ~> toTablePiezoQuotidien
   EOT
}

resource "azurerm_data_factory_pipeline" "pipeline_copy_data_in_db" {
  name            = "copy_data_in_db"
  data_factory_id = azurerm_data_factory.data_factory.id
  folder = "CopyInDB"
  activities_json = <<JSON
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
        },
        {
            "name": "copy data in tables info",
            "type": "ExecuteDataFlow",
            "dependsOn": [
                {
                    "activity": "Data flow copy data weather",
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
                "dataflow": {
                    "referenceName": "${azurerm_data_factory_data_flow.copy_data_tables_infos.name}",
                    "type": "DataFlowReference"
                },
                "compute": {
                    "coreCount": 8,
                    "computeType": "General"
                },
                "traceLevel": "Fine"
            }
        },
        {
            "name": "copy data mesure in table piezo",
            "type": "ExecuteDataFlow",
            "dependsOn": [
                {
                    "activity": "copy data in tables info",
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
                "dataflow": {
                    "referenceName": "${azurerm_data_factory_data_flow.copy_data_table_piezo_quotidien.name}",
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
  frequency  = "Month"
  interval   = 1
  start_time = "2025-04-08T10:00:00Z"
  time_zone  = "Romance Standard Time"
  schedule {
    minutes       = [0]
    hours         = [10]
    days_of_month = [8]
  }
}

resource "azurerm_data_factory_trigger_schedule" "trigger_schedule_db" {
  name            = "trigger_schedule_db"
  data_factory_id = azurerm_data_factory.data_factory.id

  pipeline {
    name = azurerm_data_factory_pipeline.pipeline_copy_data_in_db.name
  }
  frequency  = "Month"
  interval   = 1
  start_time = "2025-04-08T10:00:00Z"
  time_zone  = "Romance Standard Time"
  schedule {
    minutes       = [0]
    hours         = [0]
    days_of_month = [9]
  }
}