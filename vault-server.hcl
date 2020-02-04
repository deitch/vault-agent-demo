storage "file" {
  path = "./data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_cert_file = "./certs/server/cert.pem"
  tls_key_file = "./certs/server/key.pem"
}

