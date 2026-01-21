    ACR_NAME="acrprojetenviroment"
    RESOURCE_GROUP="RG_Projet_certif_SDELVAL"
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)
    ACR_IMAGE_NAME="api"

    cd api/
    az acr login --name $ACR_NAME
    docker build . -t "$ACR_LOGIN_SERVER/$ACR_IMAGE_NAME"
    docker push $ACR_LOGIN_SERVER/$ACR_IMAGE_NAME