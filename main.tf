# Following assumptions are made for the challenge 1
# - Terraform is the tool used for IaaC 
# - The cloud provider is assumed to be azure
# - 3 Tier environment is Web server / Application Server / Data server 
# - there will be 1 resource group 
# - 1 virtual network 
# - 1 storage account
# - 3 subnets - web / app / data
# - 3 NSG - web / app / data
#     - rules should be added for each NSG ... only certain ports will be allowed from one subnet to another ..
#      - only sample nsg rules are provided
# - 3 Network interface - web/ app / data


resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "vnetwork" {
  name                = var.virtual_netowrk_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet - web server 
resource "azurerm_subnet" "web-subnet" {
  name                 = "web-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet - app server 
resource "azurerm_subnet" "app-subnet" {
  name                 = "app-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create subnet - data server 
resource "azurerm_subnet" "data-subnet" {
  name                 = "data-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule for web subnet
resource "azurerm_network_security_group" "web-nsg" {
  name                = "web-nsg-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Security Group and rule for app subnet
resource "azurerm_network_security_group" "app-nsg" {
  name                = "app-nsg-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Security Group and rule for data subnet
resource "azurerm_network_security_group" "data-nsg" {
  name                = "data-nsg-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface for web server
resource "azurerm_network_interface" "webnic" {
  name                = "webnic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create network interface for app server
resource "azurerm_network_interface" "appnic" {
  name                = "appnic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create network interface for data server
resource "azurerm_network_interface" "datanic" {
  name                = "datanic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.data-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface - webserver
resource "azurerm_network_interface_security_group_association" "web" {
  network_interface_id      = azurerm_network_interface.webnic.id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}

# Connect the security group to the network interface - appserver
resource "azurerm_network_interface_security_group_association" "web" {
  network_interface_id      = azurerm_network_interface.appnic.id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}

# Connect the security group to the network interface - dataserver
resource "azurerm_network_interface_security_group_association" "data" {
  network_interface_id      = azurerm_network_interface.datanic.id
  network_security_group_id = azurerm_network_security_group.data-nsg.id
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storageaccount" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an  web SSH key
resource "tls_private_key" "web_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create (and display) an app SSH key
resource "tls_private_key" "app_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create (and display) an data SSH key
resource "tls_private_key" "data_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine for web 
resource "azurerm_linux_virtual_machine" "webvm" {
  name                  = "web-01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.webnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "web-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.web_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
  }
}

# Create virtual machine for app
resource "azurerm_linux_virtual_machine" "appvm" {
  name                  = "app-01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.webnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "app-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.app_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
  }
}

# Create virtual machine for data
resource "azurerm_linux_virtual_machine" "datavm" {
  name                  = "data-01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.datanic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "data-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.data_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
  }
}