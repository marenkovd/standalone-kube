#!/bin/bash
set -e -x

LOCAL_IP=$1
OPENSSL_CNF_FILENAME="openssl.cnf"
CA_KEY_FILENAME="ca-key.pem"
CA_CERT_FILENAME="ca.pem"
API_KEY_FILENAME="api-key.pem"
API_CSR_FILENAME="api.csr"
API_CERT_FILENAME="api.pem"

cat > "${OPENSSL_CNF_FILENAME}" <<-EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = ${LOCAL_IP}
IP.2 = ${LOCAL_IP}
EOF


openssl genrsa -out ${CA_KEY_FILENAME} 2048  
openssl req -x509 -new -nodes -key ${CA_KEY_FILENAME} -days 10000 -out ${CA_CERT_FILENAME} -subj "/CN=kube-ca"  
openssl genrsa -out ${API_KEY_FILENAME} 2048
openssl req -new -key ${API_KEY_FILENAME} -out ${API_CSR_FILENAME} -subj "/CN=kube-apiserver" -config ${OPENSSL_CNF_FILENAME} 
openssl x509 -req -in ${API_CSR_FILENAME} -CA ${CA_CERT_FILENAME} -CAkey ${CA_KEY_FILENAME} -CAcreateserial -out ${API_CERT_FILENAME} -days 365 -extensions v3_req -extfile ${OPENSSL_CNF_FILENAME} 

