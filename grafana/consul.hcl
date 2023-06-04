log_level = "ERROR"
advertise_addr = "xxx"
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
ui_config {
  enabled = true
}
server = true
bootstrap = true
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
