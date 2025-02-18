
# Fetch the public IP address of the terminal
locals {
  public_ip = chomp(data.external.get_ip.result.public_ip)
}
data "external" "get_ip" {
  program = ["bash", "-c", "curl -s ifconfig.me | jq -R '{\"public_ip\": .}'"]
}
