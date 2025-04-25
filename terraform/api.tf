resource "azurerm_container_registry" "acr" {
  name                = "acrprojetenviroment"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Basic"
  admin_enabled       = true
  depends_on = [azurerm_postgresql_flexible_server.postgres_server]
}

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<EOT
    ACR_NAME=${azurerm_container_registry.acr.name}
    RESOURCE_GROUP=${azurerm_resource_group.resource_group.name}
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)
    ACR_IMAGE_NAME="api"

    cd ../api/
    az acr login --name $ACR_NAME
    docker tag $ACR_IMAGE_NAME $ACR_LOGIN_SERVER/$ACR_IMAGE_NAME
    docker push $ACR_LOGIN_SERVER/$ACR_IMAGE_NAME

    EOT
  }
  depends_on = [azurerm_container_registry.acr]
}


resource "azurerm_container_group" "container_group" {
  name                = "api-sd-projet-certif"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"
  dns_name_label      = "aci-projet-certif"

  image_registry_credential{
    server = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  container {
    name   = "container-api-sd-projet-certif"
    image  = "${azurerm_container_registry.acr.login_server}/api"
    cpu    = "1"
    memory = "1"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
        IS_POSTGRES=0
        DB_USERNAME=""
        DB_HOSTNAME=""
        DB_PORT="5432"
        DB_NAME=""    
        SECRET_KEY="your_secret_key"
        ALGORITHM="HS256"
        ACCESS_TOKEN_EXPIRE_MINUTES=30
    }

    secure_environment_variables = {
      DB_PASSWORD=""
    }
  }

  depends_on = [null_resource.docker_push]
}