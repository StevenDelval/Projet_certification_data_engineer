# Variables pour le groupe de ressources
variable "resource_group_location" {
  description = "Emplacement du groupe de ressources."
  type        = string
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources."
  type        = string
}

# Variables pour le compte de stockage Data Lake
variable "data_lake_name" {
  description = "Nom du compte de stockage Data Lake."
  type        = string
}

variable "filesystem_names" {
  description = "Liste des noms des fichiers systèmes dans Data Lake."
  type        = list(string)
}

variable "folders_names_donnees_meteo" {
  description = "Liste des dossiers à créer dans Data Lake pour les données météorologiques."
  type        = list(string)
}

variable "donnees_meteo_filesystems" {
  description = "Index du filesystem à utiliser pour les dossiers de données météo."
  type        = string
}

variable "admin_login" {
  description = "Nom d'utilisateur de l'administrateur de la base de données SQL Azure."
  type        = string
}

variable "admin_password" {
  description = "Mot de passe de l'administrateur de la base de données SQL Azure. Assurez-vous qu'il respecte les exigences de sécurité."
  type        = string
  sensitive   = true
}

variable "readonly_username" {
  type        = string
  description = "Nom de l'utilisateur en lecture seule"
  default     = "readonly_user"
}

variable "readonly_password" {
  type        = string
  description = "Mot de passe de l'utilisateur readonly"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "SECRET_KEY pour l'api"
  sensitive   = true
}

variable "algorithm" {
  type        = string
  description = "ALGORITHM pour l'api"
  sensitive   = true
}
