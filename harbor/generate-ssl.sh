#!/bin/bash
# written by Hosein Yousefi <yousefi.hosein.o@gmail.com>
# Generate your selfsigned certificate as easy as you want. :D

echo "[PREPARING TO GENERATE SELF SIGNED CERTIFICATE]"

if [[ -z $HARBOR_DOMAIN_NAME ]]
then
	echo "[Generate certificates :: ERROR] First You need to define HARBOR_DOMAIN_NAME."
	echo "[HELP] export HARBOR_DOMAIN_NAME=harbor.internal"
	exit 1
fi

if [[ -e harbor-openssl ]]
then
	echo "[Generate certificates :: WARNING] harbor-openssl directory exists, you need to delete it first."
	exit 1

fi

mkdir harbor-openssl && cd harbor-openssl

echo "[Generate certificates :: INFO] Generating CA certs..."
openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=general.internal/C=US/L=San Fransisco" \
            -keyout rootCA.key -out rootCA.crt &>/dev/null

sleep 1s

echo "[Generate certificates :: INFO] Create CSR for certificates..."

openssl genrsa -out server.key 2048 &>/dev/null

cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = ${HARBOR_DOMAIN_NAME}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${HARBOR_DOMAIN_NAME}

EOF

openssl req -new -key server.key -out server.csr -config csr.conf &>/dev/null

echo "[Generate certificates :: INFO] Create certificates and signe..."

cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${HARBOR_DOMAIN_NAME}

EOF

openssl x509 -req \
    -in server.csr \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out server.crt \
    -days 365 \
    -sha256 -extfile cert.conf &>/dev/null

echo "[Generate certificates :: INFO] SSL certificates are created successfuly, use server.key and server.crt"
echo "[Generate certificates :: INFO] deleting remained files."

rm -rf rootCA.key rootCA.crt server.csr csr.conf cert.conf

chmod +r server.*

cd - &>/dev/null


