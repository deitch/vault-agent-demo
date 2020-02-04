# Vault agent demo

## TL;DR

1. Generate CA, server and client certs
1. Start Vault server
1. Initialize
1. Unseal
1. Create a Policy
1. Enable certs as auth method
1. Add CA cert
1. Enable kv secrets
1. Store a secret
1. Launch the agent
1. See the rendered file
1. Update the secret
1. See the updated file

## Steps

### Generate CA and Certs

Use any tools you want to generate CA and certs. For the following examples, I sed `ca` from https://github.com/deitch/ssl-utils

```sh
mkdir -p certs/client certs/ca certs/server out
# generate CA
ca init --subject "/CN=client.example.com/OU=Example Corp/C=US/ST=NY" --ca-key ./certs/ca/key.pem --ca-cert ./certs/ca/cert.pem
# generate server cert
ca sign subject --subject "/CN=vault.example.com/OU=Example Corp/C=US/ST=NY" --key ./certs/server/key.pem --cert ./certs/server/cert.pem --ca-key ./certs/ca/key.pem --ca-cert ./certs/ca/cert.pem --san 127.0.0.1,vault.example.com
# generate client cert
ca sign subject --subject "/CN=client.example.com/OU=Example Corp/C=US/ST=NY" --key ./certs/client/key.pem --cert ./certs/client/cert.pem --ca-key ./certs/ca/key.pem --ca-cert ./certs/ca/cert.pem
```

### Start Vault

```sh
vault server -config ./vault-server.hcl
```

### Initialize

For this and all subsequent client commands, set the following environment variables:

```sh
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT=./certs/ca/cert.pem
```

Check status:

```sh
vault status
```

```sh
# for less secure but good for demo
vault operator init -key-shares=1 -key-threshold=1
# more secure
vault operator init
```

Save your unseal keys and initial root token, or you are lost!

### Unseal

```sh
vault operator unseal
# enter the saved unseal key when asked
```

### Create a Policy for the Agent

```sh
vault policy write myapp ./agent-policy.hcl
```

### Enable Certs

```sh
vault auth enable
```

### Add CA Cert for the Policy

```sh
vault write auth/cert/certs/web \
    display_name=web \
    policies=myapp \
    certificate=@./certs/ca/cert.pem \
    ttl=3600
```

### Enable KV Secrets

```sh
vault secrets enable -path=secret kv-v2
```

### Store a Secret

```sh
vault kv put secret/myapp username=jlima password='s3cr3t!!'
```

### Launch the Agent

```sh
vault agent -config ./vault-agent.hcl
```

### See the Rendered File

```sh
cat ./myapp
```

### Update the Secret

```sh
vault kv put secret/myapp username=jlima password='new45&&'
```

### See Updated File

This may take some time. The default cache for the agent is 5 minutes.

```sh
cat ./myapp
```

