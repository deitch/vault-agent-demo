pid_file = "./out/pidfile"

vault {
        address = "https://127.0.0.1:8200"
        ca_cert = "./certs/ca/cert.pem"
        client_cert = "./certs/client/cert.pem"
        client_key = "./certs/client/key.pem"
}

auto_auth {
        method "cert" {
        }

  sink {
    type = "file"

    config = {
      path = "./out/agent-token"
    }
  }

}

template {
  source      = "./myapp.ctmpl"
  destination = "./out/myapp"
}

