# 仮想ネットワーク
resource "azurerm_virtual_network" "this" {
  name = "${var.virtual_nw_name}-${var.suffix}-${random_id.this.b64_url}"
  address_space = ["${var.virtual_nw_address_space}"]
  location = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

# インターフェースへ適用するサブネット設定
resource "azurerm_subnet" "this" {
    name                 = "${var.subnet_name}-${var.suffix}-${random_id.this.b64_url}"
    resource_group_name  = data.azurerm_resource_group.this.name
    virtual_network_name = "${azurerm_virtual_network.this.name}"
    address_prefixes       = ["10.0.2.0/24"]
}

# パブリックIPアドレス
resource "azurerm_public_ip" "this" {
  name = "${var.public_ip_name}-${var.suffix}-${random_id.this.b64_url}"
  location =  data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method = "Static"
}

# ネットワークセキュリティグループ
resource "azurerm_network_security_group" "this" {
    name ="${var.security_group}-${var.suffix}-${random_id.this.b64_url}"
    location = data.azurerm_resource_group.this.location
    resource_group_name = data.azurerm_resource_group.this.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.global_ip
        destination_address_prefix = "*"
    }
    # security_rule {
    #     name                       = "HTTP"
    #     priority                   = 1001
    #     direction                  = "Inbound"   
    #     access                     = "Allow"
    #     protocol                   = "Tcp"
    #     source_port_range          = "*"
    #     destination_port_range     = "80"
    #     source_address_prefix      = "*"
    #     destination_address_prefix = "*"
    # }
}

# ネットワーク インターフェイス
resource "azurerm_network_interface" "this" {
    name                = "${var.network_interface_name}-${var.suffix}-${random_id.this.b64_url}"
    location = data.azurerm_resource_group.this.location
    resource_group_name = data.azurerm_resource_group.this.name
    # network_security_group_id = "${azurerm_network_security_group.this.id}"

    ip_configuration {
        name                          = "${var.NIC_name}-${var.suffix}-${random_id.this.b64_url}"
        subnet_id                     = "${azurerm_subnet.this.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.this.id}"
    }
}

# ネットワークインターフェースとセキュリティグループを関連付け
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}