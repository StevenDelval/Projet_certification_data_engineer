import azure.functions as func
import logging
from datetime import datetime
import requests
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
    """
    Crée une instance du client Azure Data Lake Service.
    
    Args:
        account_name (str): Nom du compte de stockage Azure.
        account_key (str): Clé d'accès au compte de stockage.
    
    Returns:
        DataLakeServiceClient: Objet client permettant d'interagir avec Azure Data Lake.
    """
    return DataLakeServiceClient(
        account_url=f"https://{account_name}.dfs.core.windows.net",
        credential=account_key
    )

# Création de l'application Azure Function
app = func.FunctionApp()

@app.route(route="collecte_api_hubeau_data", auth_level=func.AuthLevel.FUNCTION, methods=["POST"])
def collecte_api_hubeau_data(req: func.HttpRequest) -> func.HttpResponse:
    """
    Fonction Azure qui récupère des données de l'API Hubeau et les stocke dans Azure Data Lake.
    
    Args:
        req (func.HttpRequest): Requête HTTP contenant le paramètre 'code_bss'.
    
    Returns:
        func.HttpResponse: Réponse HTTP indiquant le succès ou l'échec de l'opération.
    """
    logging.info('Python HTTP trigger function processed a request.')
    
    api_url = "https://hubeau.eaufrance.fr/api/v1/niveaux_nappes/chroniques"
    try:
        # Extraction du corps de la requête JSON
        req_body = req.get_json()
        code_bss = req_body.get("code_bss")

        date_fin_mesure = datetime.now().strftime("%Y-%m-%d") # Date de fin : aujourd'hui

        params = {
            "code_bss": code_bss,
            "date_debut_mesure": "2000-01-01",
            "date_fin_mesure": date_fin_mesure,
            "size": 1000 # Nombre maximal de résultats par page
        }

        # Vérification du paramètre requis
        if not code_bss:
            return func.HttpResponse(
                json.dumps({"error": "Le paramètre 'code_bss' est requis."}),
                mimetype="application/json",
                status_code=400
            )
        
        all_data = [] # Liste pour stocker toutes les données récupérées
        page = 1 # Numéro de page initial

        while True:  # Boucle de pagination
            try:
                params["page"] = page
                response = requests.get(api_url, params=params)
                response.raise_for_status()  # Lève une exception en cas d'erreur HTTP (4xx ou 5xx)
                data = response.json()

                # Vérification si la page actuelle contient des données
                if not data['data']:  
                    break # Sortie de la boucle si aucune donnée

                for item in data['data']:
                    # Nettoyage et conversion des données pour chaque élément
                    item['date_mesure'] = datetime.strptime(item['date_mesure'], '%Y-%m-%d').date()
                    item['niveau_nappe_eau'] = pd.to_numeric(item['niveau_nappe_eau'], errors='coerce') # Conversion en numérique
                    item['profondeur_nappe'] = pd.to_numeric(item['profondeur_nappe'], errors='coerce') # Conversion et inversion du signe

                all_data.extend(data['data']) # Ajout des données de la page à la liste complète
                page += 1 # Incrémentation du numéro de page
            except requests.exceptions.RequestException as e:
                logging.error(f"Erreur lors de la requête à l'API Hubeau: : {str(e)}")
                return func.HttpResponse(
                    json.dumps({"error": str(e)}),
                    mimetype="application/json",
                    status_code=500
                )
        
        # Connexion à Azure Data Lake et envoi du fichier
        logging.info("Connexion à Azure Data Lake.")
        service_client = get_service_client(STORAGE_ACCOUNT_NAME, STORAGE_ACCOUNT_KEY)
        file_system_client = service_client.get_file_system_client(file_system=FILE_SYSTEM_NAME)
        directory_client = file_system_client.get_directory_client(DIRECTORY_NAME)
        file_client = directory_client.get_file_client(f"{code_bss.replace('/','-')}.parquet")

        logging.info("Téléversement du fichier Parquet vers Azure Data Lake.")
        # Écriture des données au format Parquet dans Azure Data Lake
        with BytesIO() as output:
            table = pa.Table.from_pylist(all_data)
            pq.write_table(table, output)
            output.seek(0)
            file_client.upload_data(output, overwrite=True)
        
        return func.HttpResponse(
            json.dumps({"message": f"Données stockées sous {code_bss.replace('/','-')} dans Data Lake."}),
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