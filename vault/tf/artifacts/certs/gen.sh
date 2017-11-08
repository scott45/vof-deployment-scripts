#!/bin/bash -e

echo "creating rootCA.key and rootCA.pem ..."
openssl req -x509 -new -nodes -days 9999 -config rootCA.cnf -out rootCA.pem

echo "creating the etcd.key and etcd.csr...."
openssl req -new -out etcd.csr -config etcd.cnf

echo "creating the etcd-client.key and etcd-client.csr...."
openssl req -new -out etcd-client.csr -config etcd-client.cnf

echo "signing etcd.csr..."
openssl x509 -req -days 9999 -in etcd.csr -CA rootCA.pem -CAkey rootCA.key \
        -CAcreateserial -extensions v3_req -out etcd.crt -extfile etcd.cnf

echo "signing etcd-client.csr..."
openssl x509 -req -days 9999 -in etcd-client.csr -CA rootCA.pem -CAkey rootCA.key \
        -CAcreateserial -extensions v3_req -out etcd-client.crt -extfile etcd-client.cnf

echo "etcd.crt is generated:"
openssl x509 -text -noout -in etcd.crt

echo "etcd-client.crt is generated:"
openssl x509 -text -noout -in etcd-client.crt

echo "creating the vault.key and vault.csr...."
openssl req -new -out vault.csr -config vault.cnf

echo "creating the vault-client.key and vault-client.csr...."
openssl req -new -out vault-client.csr -config vault-client.cnf

echo "signing vault.csr..."
openssl x509 -req -days 9999 -in vault.csr -CA rootCA.pem -CAkey rootCA.key \
        -CAcreateserial -extensions v3_req -out vault.crt -extfile vault.cnf

echo "signing vault-client.csr..."
openssl x509 -req -days 9999 -in vault-client.csr -CA rootCA.pem -CAkey rootCA.key \
        -CAcreateserial -extensions v3_req -out vault-client.crt -extfile vault-client.cnf

echo "keep the secret to yourself."
chmod 600 *.key

echo "vault.crt is generated:"
openssl x509 -text -noout -in vault.crt

echo "vault-client.crt is generated:"
openssl x509 -text -noout -in vault-client.crt
