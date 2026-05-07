output "server_ips" {
  value = {
    for k, v in module.app_servers : k => v.public_ip
  }
}

output "server_ids" {
  value = {
    for k, v in module.app_servers : k => v.instance_id
  }
}

