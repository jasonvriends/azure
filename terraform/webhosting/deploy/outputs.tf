output "instance_public_ip" {
  description = "Public IP of Azure instance"
  value       = azurerm_public_ip.pip_webhosting.*.ip_address
}