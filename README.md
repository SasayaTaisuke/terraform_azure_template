# WIP
# terraform_azure_template
## Description
* Terraformで所与のリソースグループにAzureVMを作るテンプレート
* VMイメージによってはresource provisionerで作成できないためlocal-exec+AzureCLIで構築
  - https://github.com/hashicorp/terraform-provider-azurerm/issues/6117
