import azure.functions as func
import logging
from dotenv import load_dotenv
import pandas as pd
import json
import os
from azure.storage.filedatalake import DataLakeServiceClient
from io import BytesIO

# Load environment variables from .env file
load_dotenv()

# Configuration for Azure Data Lake
STORAGE_ACCOUNT_NAME = os.getenv("STORAGE_ACCOUNT_NAME")
STORAGE_ACCOUNT_KEY = os.getenv("STORAGE_ACCOUNT_KEY")
FILE_SYSTEM_NAME = os.getenv("FILE_SYSTEM_NAME")
DIRECTORY_NAME = os.getenv("DIRECTORY_NAME")

# Function to create the DataLakeServiceClient instance
def get_service_client(account_name, account_key):
    """Create a DataLakeServiceClient instance.
    
    Args:
        account_name (str): Azure Storage account name.
        account_key (str): Azure Storage account key.
        
    Returns:
        DataLakeServiceClient: A client for interacting with the Data Lake service.
    """
    return DataLakeServiceClient(
        account_url=f"https://{account_name}.dfs.core.windows.net",
        credential=account_key
    )

# Main function to process the HTTP request
app = func.FunctionApp()

@app.route(route="collecte_csv_weather_data", auth_level=func.AuthLevel.FUNCTION)
def collecte_csv_weather_data(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("HTTP function is processing a request.")

    # Retrieve the CSV file URL from the request parameters
    url_csv_file = req.params.get("url_csv_file")
    file_name = req.params.get("file_name", url_csv_file)  # Default to "weather_data.parquet" if not provided

    # Validate the presence of the 'url_csv_file' parameter
    if not url_csv_file:
        try:
            req_body = req.get_json()
            url_csv_file = req_body.get("url_csv_file")
            file_name = req_body.get("file_name", file_name)  # Use "file_name" if provided in the body
        except ValueError:
            pass

    if not url_csv_file:
        return func.HttpResponse(
            "The 'url_csv_file' parameter is missing from the query string or request body.",
            status_code=400
        )

    try:
        
        # Read the CSV file directly from the URL into a pandas DataFrame
        logging.info("Start read the CSV file.")
        df = pd.read_csv(url_csv_file, compression="gzip", sep=";")
        logging.info("Finish read the CSV file .")

        # Create a client instance for Azure Data Lake
        logging.info("Create a client instance for Azure Data Lake.")
        service_client = get_service_client(STORAGE_ACCOUNT_NAME, STORAGE_ACCOUNT_KEY)
        file_system_client = service_client.get_file_system_client(file_system=FILE_SYSTEM_NAME)
        directory_client = file_system_client.get_directory_client(DIRECTORY_NAME)
        file_client = directory_client.get_file_client(file_name)

        # Upload the Parquet file to Data Lake
        logging.info("Upload the Parquet file to Data Lake.")
        file_client.upload_data(df.to_parquet(index=False), overwrite=True)

        return func.HttpResponse(
            json.dumps({"message": f"CSV successfully converted to Parquet and stored in Data Lake as {file_name}"}),
            mimetype="application/json",
            status_code=200
        )

    except Exception as e:
        logging.error(f"Error processing the file: {str(e)}")
        return func.HttpResponse(
            json.dumps({"error": str(e)}),
            mimetype="application/json",
            status_code=500
        )
