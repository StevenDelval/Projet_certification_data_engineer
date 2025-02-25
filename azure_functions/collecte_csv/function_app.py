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

@app.route(route="collecte_csv_weather_data", auth_level=func.AuthLevel.FUNCTION, methods=["POST"])
def collecte_csv_weather_data(req: func.HttpRequest) -> func.HttpResponse:
    """Endpoint pour traiter un fichier CSV compressé et l'enregistrer en format Parquet dans Azure Data Lake.
    
    Args:
        req (func.HttpRequest): Requête HTTP contenant l'URL du fichier CSV et le nom du fichier de sortie (optionnel).
    
    Returns:
        func.HttpResponse: Réponse JSON confirmant l'opération ou signalant une erreur.
    """
    logging.info("Requête POST reçue pour traiter un fichier CSV.")

    try:
        # Extraction du corps de la requête JSON
        req_body = req.get_json()
        url_csv_file = req_body.get("url_csv_file")
        file_name = req_body.get("file_name", "weather_data.parquet")  # Nom par défaut

        # Vérification du paramètre requis
        if not url_csv_file:
            return func.HttpResponse(
                json.dumps({"error": "Le paramètre 'url_csv_file' est requis."}),
                mimetype="application/json",
                status_code=400
            )

        chunksize: int = 100000  # Taille des morceaux pour le traitement en lot
        logging.info("Début de la lecture du fichier CSV.")

        with BytesIO() as output:
            writer = None  # Initialisation de l'écrivain Parquet
            
            for chunk in pd.read_csv(url_csv_file, compression="gzip", parse_dates=["DATE"], chunksize=chunksize, sep=";"):
                # Filtrer les données selon les conditions spécifiques
                mask = (chunk["LAMBX"] >= 5300) & (chunk["LAMBX"] <= 7500) & (chunk["LAMBY"] >= 24000)
                table = pa.Table.from_pandas(chunk[mask])

                # Création du writer Parquet si c'est le premier chunk
                if writer is None:
                    writer = pq.ParquetWriter(output, table.schema)

                # Écriture des données filtrées dans Parquet
                writer.write_table(table)

            logging.info("Lecture du fichier CSV terminée.")

            # Connexion à Azure Data Lake et envoi du fichier
            logging.info("Connexion à Azure Data Lake.")
            service_client = get_service_client(STORAGE_ACCOUNT_NAME, STORAGE_ACCOUNT_KEY)
            file_system_client = service_client.get_file_system_client(file_system=FILE_SYSTEM_NAME)
            directory_client = file_system_client.get_directory_client(DIRECTORY_NAME)
            file_client = directory_client.get_file_client(file_name)

            logging.info("Téléversement du fichier Parquet vers Azure Data Lake.")
            if writer:
                writer.close()
                output.seek(0)  # Réinitialisation du buffer
                file_client.upload_data(output, overwrite=True)

        return func.HttpResponse(
            json.dumps({"message": f"CSV converti en Parquet et stocké sous {file_name} dans Data Lake."}),
            mimetype="application/json",
            status_code=200
        )

    except Exception as e:
        logging.error(f"Erreur lors du traitement du fichier : {str(e)}")
        return func.HttpResponse(
            json.dumps({"error": str(e)}),
            mimetype="application/json",
            status_code=500
        )
