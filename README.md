# Projet certification data engineer

## Description
Ce projet implémente une plateforme complète de collecte, stockage et mise à disposition de données environnementales sur Azure. Il répond aux exigences des blocs de compétences 2 (E4) et 4 (E7) du titre professionnel, couvrant l'ensemble du cycle de vie des données : de l'extraction automatisée depuis diverses sources jusqu'à la mise à disposition via API REST sécurisée, en passant par le stockage dans un Data Lake et une base de données relationnelle.

## Architecture
Le projet est organisé en plusieurs composants :

- Automatiser la collecte de données environnementales (météo, piézomètres, capteurs, qualité de l'eau)
- Stocker et organiser les données dans un Data Lake Azure Gen2 avec une structure hiérarchique
- Mettre à disposition les données via une API REST sécurisée
- Assurer la conformité RGPD et la gouvernance des données

##  Structure du Projet
```
.
├── api/                          # API REST FastAPI 
│   ├── router/                   # Routes de l'API
│   │   ├── data_router.py        # Endpoints données
│   │   └── user_router.py        # Endpoints utilisateurs
│   ├── auth.py                   # Authentification JWT
│   ├── crud.py                   # Opérations CRUD
│   ├── database.py               # Connexion base de données
│   ├── models.py                 # Modèles SQLAlchemy
│   ├── schemas.py                # Schémas Pydantic
│   ├── security.py               # Gestion sécurité
│   ├── tests/                    # Tests unitaires
│   ├── Dockerfile                # Conteneurisation
│   └── requirements.txt          # Dépendances Python
├── azure_functions/              # Collecte automatisée 
│   ├── collecte_api/             # Extraction depuis APIs
│   │   ├── function_app.py       # Logique de collecte API
│   │   ├── host.json             # Configuration Azure Functions
│   │   └── requirements.txt      # Dépendances
│   ├── collecte_csv/             # Extraction depuis fichiers
│   │   ├── function_app.py       # Logique de collecte CSV
│   │   └── requirements.txt      # Dépendances
│   └── commande.txt              # Commandes de déploiement
├── base_de_donnees/              # Scripts SQL 
│   ├── api_service.sql           # Schéma base de données
│   ├── table_data.sql            # Tables de données
│   ├── control_tables.sql        # Tables de contrôle
│   ├── ct_storage_procedure.sql  # Procédures stockées
│   └── test.sql                  # Scripts de test
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Configuration principale
│   ├── providers.tf              # Providers Azure
│   ├── variables.tf              # Variables
│   ├── terraform.tfvars          # Valeurs des variables
│   ├── api.tf                    # Ressources API
│   ├── azure_function.tf         # Ressources Functions
│   ├── database.tf               # Ressources Database
│   ├── databricks.tf             # Ressources Databricks
│   ├── datafactory.tf            # Ressources Data Factory
│   ├── datalake.tf               # Ressources Data Lake 
│   ├── logs.tf                   # Ressources Monitoring 
│   └── modules/                  # Modules réutilisables
├── schemas/                      # Documentation technique
│   ├── flowchart.md              # Diagrammes de flux
│   └── schema_base_de_donnees.md # Modélisation MERISE 
├── README.md                     # Documentation projet
└── requirements.txt              # Dépendances globales
```
## Technologies utilisées
### Cloud & Infrastructure

- Microsoft Azure - Plateforme cloud principale
- Azure Data Lake Storage Gen2 - Stockage des données brutes et transformées
- Azure Functions - Collecte automatisée et traitement serverless
- Azure Data Factory - Orchestration des pipelines de données
- Azure Databricks - Traitement et analyse de données à grande échelle
- Azure SQL Database - Base de données relationnelle
- Azure Container Instances - Hébergement de l'API conteneurisée
- Azure Monitor & Log Analytics - Monitoring et observabilité

### Infrastructure as Code

- Terraform - Provisionnement et gestion de l'infrastructure Azure
- Docker - Conteneurisation de l'API

### Backend & API

- Python 3.10+ - Langage principal
- FastAPI - Framework web moderne pour l'API REST
- SQLAlchemy - ORM pour la gestion de la base de données
- Pydantic - Validation des données et schémas
- PyJWT - Authentification et autorisation JWT
- Uvicorn - Serveur ASGI pour FastAPI


## Installations

### Prérequis
- Python 3.10+
- Azure CLI
- Terraform 1.0+
- Docker
- Compte Azure avec les permissions appropriées
- Git

### 1. Cloner le repository
```
git clone https://github.com/StevenDelval/Projet_certification_data_engineer.git
cd Projet_certification_data_engineer

```

### 2. Initialiser Terraform
```sh
cd terraform
terraform init
```

### 3. Configurer les variables
Créer un fichier terraform.tfvars à partir de l'exemple ci-dessous :
```sh
# Configuration du Resource Group
resource_group_name     = "RG_Projet_certif_VOTRENOM"
resource_group_location = "francecentral"

# Configuration Data Lake
data_lake_name = "votredatalakename"  # Doit être unique globalement
filesystem_names = [
  "donnees-meteo",
  "donnees-piezometre",
  "donnees-capteurs",
  "modeles-machine-learning",
  "donnees-ville"
]

# Structure des dossiers
folders_names_donnees_meteo = ["quotidien", "mensuel", "maille_geographique"]
donnees_meteo_filesystems   = "donnees-meteo"

# Configuration Base de données
admin_login    = "votre_admin_login"
admin_password = "VotreMotDePasseSecurise123!"  # Minimum 8 caractères, majuscules, minuscules, chiffres et caractères spéciaux

# Utilisateur en lecture seule pour l'API
readonly_username = "readonly_api_service"
readonly_password = "MotDePasseSecurise456!"

# Configuration JWT pour l'API
secret_key = "votre_secret_key_jwt_tres_longue_et_securisee"  
algorithm  = "HS256"

# Configuration Data Factory
git_pipeline_qualite_eau_repo_url = "https://github.com/VOTRE_USERNAME/pipeline_qualite_eau.git"

# Notifications
users_notification = ["votre.email@example.com"]

# Configuration base de données externe (si applicable)
city_db_user = "votre_db_user"
city_db_pwd  = "VotreMotDePasseDB789!"
```
### 4. Déployer l'infrastructure

```sh
terraform apply
```

## Utilisation
### Prérequis : Exécution initiale des pipelines
Après le déploiement de l'infrastructure avec Terraform, vous devez exécuter manuellement les pipelines Azure Data Factory pour collecter et charger les données initiales avant d'utiliser l'API.
### Ordre d'exécution des pipelines
#### 1. Collecte des données brutes

Exécutez ces pipelines dans l'ordre suivant :

##### a) Pipeline de collecte CSV (données météo)
```sh
az datafactory pipeline create-run \
  --resource-group RG_Projet_certif_VOTRENOM \
  --factory-name ADF-projet-SD \
  --name pipeline_get_csv
```

##### b) Pipeline de collecte API (données piézométriques)
```sh
az datafactory pipeline create-run \
  --resource-group RG_Projet_certif_VOTRENOM \
  --factory-name ADF-projet-SD \
  --name pipeline_get_api
```
Temps d'attente : Patientez 5-10 minutes pour que les Azure Functions collectent les données et les stockent dans le Data Lake.
#### 2. Chargement des données dans PostgreSQL

Une fois la collecte terminée, exécutez le pipeline de copie :
```sh
az datafactory pipeline create-run \
  --resource-group RG_Projet_certif_VOTRENOM \
  --factory-name ADF-projet-SD \
  --name copy_data_in_db
```
Temps d'attente : 30-45 minutes selon le volume de données.
Vérification de l'exécution via le portail Azure

- Accédez au portail Azure : https://portal.azure.com
- Naviguez vers votre Data Factory : ADF-projet-SD
- Cliquez sur "Author & Monitor"
- Dans l'onglet "Monitor", vérifiez l'état des pipelines :
    - Succeeded : Pipeline terminé avec succès
    - In Progress : Pipeline en cours d'exécution
    - Failed : Erreur - consultez les logs

### Vérification des données dans PostgreSQL

Connectez-vous à votre base de données PostgreSQL pour vérifier que les données sont bien chargées :

####  Via Azure CLI
```sh
az postgres flexible-server connect \
  --name my-sqlserver-sd \
  --admin-user Sdelval \
  --database api_service
```
```
-- Vérifier les données météo
SELECT COUNT(*) FROM Meteo;

-- Vérifier les données piézométriques
SELECT COUNT(*) FROM Nappe;
SELECT COUNT(*) FROM Info_nappe;
SELECT COUNT(*) FROM Continuite;
SELECT COUNT(*) FROM Nature_mesure;
SELECT COUNT(*) FROM Producteur;
```

### Automatisation future

Après cette exécution initiale, les pipelines s'exécuteront automatiquement selon le calendrier configuré :

| Pipeline  |	Fréquence |	Jour |	Heure |
|:-------- |:-------- |:-------- |:-------- |
|pipeline_get_csv 	|Mensuel |	8 du mois |	10h00|
|pipeline_get_api 	|Mensuel |	8 du mois |	10h00|
|copy_data_in_db 	|Mensuel |	9 du mois |	00h00|
|pipeline_delete_user (RGPD)| 	Quotidien |	Tous les jours |	00h00|

### Démarrage de l'API
Après le déploiement Terraform, l'API est automatiquement accessible via Azure Container Instances.
### URL d'accès
```
http://aci-sd-projet.francecentral.azurecontainer.io
```

### Documentation interactive
Accédez à la documentation Swagger UI :
```
http://aci-sd-projet.francecentral.azurecontainer.io/docs
```
### Authentification
#### 1. Créer un compte utilisateur
Endpoint: POST /user/register
```sh
curl -X POST "http://aci-sd-projet.francecentral.azurecontainer.io/user/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "votre_username",
    "email": "votre.email@example.com",
    "password": "VotreMotDePasse123!",
    "consent_given": true
  }'
```
Réponse:
```json
{
  "id": 1,
  "username": "votre_username",
  "email": "votre.email@example.com",
  "is_active": true,
  "consent_given": true,
  "created_at": "2024-01-15T10:30:00Z"
}
```

#### 2. Se connecter et obtenir un token JWT

Endpoint: POST /user/login
```sh
curl -X POST "http://aci-sd-projet.francecentral.azurecontainer.io/user/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=votre_username&password=VotreMotDePasse123!"
```
Réponse:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```
Important: Le token expire après 30 minutes. Conservez-le de manière sécurisée.

**Utilisation des endpoints de données**

Tous les endpoints sous /data nécessitent une authentification JWT.

#### 3. Récupérer des données météorologiques

Endpoint: POST /data/meteo/
```sh
curl -X POST "http://aci-sd-projet.francecentral.azurecontainer.io/data/meteo/" \
  -H "Authorization: Bearer VOTRE_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "input_date": "2024-01-15",
    "lambx": 652500.0,
    "lamby": 6862500.0
  }'
```
Réponse:
```json
{
  "date": "2024-01-15",
  "lambx": 652500.0,
  "lamby": 6862500.0,
  "temperature": 12.5,
  "precipitation": 2.3,
  "humidity": 75.0
}
```
#### 4. Récupérer des données piézométriques (avec pagination)

Endpoint: POST /data/piezo_value/
```sh
curl -X POST "http://aci-sd-projet.francecentral.azurecontainer.io/data/piezo_value/?limit=50&offset=0" \
  -H "Authorization: Bearer VOTRE_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "code_bss": "07548X0009/F",
    "include_info": true,
    "include_continuite": true,
    "include_nature": false,
    "include_producteur": false
  }'
```
Paramètres de requête:

- limit (optionnel): Nombre de résultats par page (1-1000, défaut: 50)
- offset (optionnel): Décalage pour la pagination (défaut: 0)

Réponse:
```json
{
  "total": 1250,
  "limit": 50,
  "offset": 0,
  "results": [
    {
      "code_bss": "07548X0009/F",
      "date_mesure": "2024-01-15T10:00:00Z",
      "niveau_nappe_eau": 125.5,
      "profondeur_nappe": 15.2,
      "info": {...},
      "continuite": {...}
    }
  ]
}
```

