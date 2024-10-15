terraform {
  required_providers {
    azurerm = {    
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Azureプロバイダ
# バージョンによってsubscription_idを要求してくる
# 他の項目も含めcredentialはTF_VARで環境変数にセットすることを推奨
provider "azurerm" {
  features {}
  subscription_id = var.ARM_SUBSCRIPTION_ID
}

# リソースグループから作成する場合
# resource "azurerm_resource_group" "this" {
#   name     = "${var.resource_group_name}-${var.suffix}-${random_id.this.b64_url}"
#   location = var.region
#   tags     = var.tags_def
# }

data "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}"
}

resource "random_id" "this" {
  byte_length = 8
}

# Setup for VM (escape from Plugin Problem...)
# PEMのsshキーを事前に作成している
resource "terraform_data" "create_vm" {
  # triggers = {
  #   fugafuga = "fugafuga"
  # }
  provisioner "local-exec" {
    # command     = "ash create_vm_cli.sh"
    interpreter = ["/bin/ash", "-c"]
    command     = <<EOT
      az login --service-principal -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_SECRET --tenant $TENANT_ID
      az account set --subscription $SUBSCRIPTION_ID
      az vm create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $VM_NAME-$SUFFIX-$RANDOM_ID \
        --location $LOCATION \
        --size $VM_SIZE \
        --nics $NIC_NAME \
        --image $IMAGE_NAME \
        --admin-username $ADMIN_USERNAME \
        --os-disk-size-gb $OS_DISK_SIZE \
        --authentication-type ssh \
        --zone 1 \
        --ssh-key-value .ssh/id_rsa.pub
      EOT
    environment = {
      SERVICE_PRINCIPAL_ID = var.ARM_CLIENT_ID
      SERVICE_PRINCIPAL_SECRET = var.ARM_CLIENT_SECRET
      TENANT_ID = var.ARM_TENANT_ID
      SUBSCRIPTION_ID = var.ARM_SUBSCRIPTION_ID
      RESOURCE_GROUP_NAME = data.azurerm_resource_group.this.name
      VM_NAME = var.VM_name
      VM_SIZE = var.VM_size
      LOCATION = var.location
      NIC_NAME = azurerm_network_interface.this.name
      IMAGE_NAME = var.source_image_id
      ADMIN_USERNAME = var.product_user
      SUBNET = azurerm_subnet.this.name
      PUBLIC_IP = azurerm_public_ip.this.ip_address
      VNET_NAME = azurerm_virtual_network.this.name
      NSG = azurerm_network_security_group.this.id
      OS_DISK_SIZE = var.os_disk_size
      SUFFIX = var.suffix
      RANDOM_ID = random_id.this.b64_url
    }
  }
}

# WIP: SSHの疎通がとれるかどうか確認取る場合あったほうがいいか
# resource "terraform_data" "ssh-connection-check" {
#   provisioner "remote-exec" {
#       connection {
#       user     = var.product_user
#       private_key = file(".ssh/gitlab_terraform.pem")
#       host = azurerm_public_ip.this.ip_address
#       timeout = "15m"
#     }
#     inline = [
#       "echo 'SSH connection has been established!'"
#     ]
#   }
# }

# Teardown for VM and related disks
resource "terraform_data" "delete" {
   input = {
    RESOURCE_GROUP_NAME = data.azurerm_resource_group.this.name
    VM_NAME = "${var.VM_name}-${random_id.this.b64_url}"
  }
  provisioner "local-exec" {
    when       = destroy
    # command    = "ash delete_vm_and_disk.sh"
    interpreter = ["/bin/ash", "-c"]
    command     = "ash delete_vm_and_disk.sh"
    on_failure = continue
    environment = {
      RESOURCE_GROUP_NAME = self.input.RESOURCE_GROUP_NAME
      VM_NAME = self.input.VM_NAME
    }
  }
}
