sudo openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 \
   -key ca-key.pem \
   -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA " \
   -out ca-cert.pem

openssl req -newkey rsa:2048 -nodes -days 365000 \
   -keyout gitlab.local.key \
   -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=gitlab.local" \
   -out gitlab.local.csr

openssl req -newkey rsa:2048 -nodes -days 365000 \
   -keyout registry.gitlab.local.key \
   -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=registry.gitlab.local" \
   -out registry.gitlab.local.csr


openssl x509 -req -days 365000 -set_serial 01 \
   -in gitlab.local.csr \
   -extfile <(printf "subjectAltName=DNS:gitlab.local") \
   -out gitlab.local.crt \
   -CA ca-cert.pem \
   -CAkey ca-key.pem \
   -CAcreateserial

openssl x509 -req -days 365000 -set_serial 01 \
   -in registry.gitlab.local.csr \
   -extfile <(printf "subjectAltName=DNS:registry.gitlab.local") \
   -out registry.gitlab.local.crt \
   -CA ca-cert.pem \
   -CAkey ca-key.pem \
   -CAcreateserial


openssl genrsa -out ca.key 2048 && openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA "-out ca.crt
openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=*.example.com" -out server.csr openssl x509 -req -extfile <(printf "subjectAltName=DNS:example.com,DNS:www.example.com") -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server .crt


### WILD CARD
openssl req -newkey rsa:2048 -nodes -days 365000 \
   -keyout gitlab.local.key \
   -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=*.gitlab.local" \
   -out gitlab.local.csr

openssl x509 -req -days 365000 -set_serial 01 \
   -in gitlab.local.csr \
   -extfile <(printf "subjectAltName=DNS:gitlab.local,DNS:registry.gitlab.local") \
   -out gitlab.local.crt \
   -CA ca-cert.pem \
   -CAkey ca-key.pem \
   -CAcreateserial


sudo apt-get update -y > /dev/null
sudo apt-get install -y ca-certificates > /dev/null
sudo cp /etc/gitlab-runner/certs/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates --fresh > /dev/null
