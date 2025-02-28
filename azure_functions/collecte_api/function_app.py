import azure.functions as func
import logging
from dotenv import load_dotenv
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import json
import os
from azure.storage.filedatalake import DataLakeServiceClient
from io import BytesIO

# Charger les variables d'environnement depuis le fichier .env
load_dotenv()

# Configuration pour Azure Data Lake
STORAGE_ACCOUNT_NAME = os.getenv("STORAGE_ACCOUNT_NAME")
STORAGE_ACCOUNT_KEY = os.getenv("STORAGE_ACCOUNT_KEY")
FILE_SYSTEM_NAME = os.getenv("FILE_SYSTEM_NAME")
DIRECTORY_NAME = os.getenv("DIRECTORY_NAME")

def get_service_client(account_name: str, account_key: str) -> DataLakeServiceClient:
    """Crée une instance de DataLakeServiceClient.
    
    Args:
        account_name (str): Nom du compte de stockage Azure.
        account_key (str): Clé d'accès au compte de stockage.
    
    Returns:
        DataLakeServiceClient: Client pour interagir avec le service Azure Data Lake.
    """
    return DataLakeServiceClient(
        account_url=f"https://{account_name}.dfs.core.windows.net",
        credential=account_key
    )

# Création de l'application Azure Function
app = func.FunctionApp()

@app.route(route="collecte_api_hubeau_data", auth_level=func.AuthLevel.Function, methods=["POST"])
def collecte_api_hubeau_data(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )