all: ca api worker admin

clean:
	rm -f *.key *.srl *.csr *.pem *.p12

ca:
	openssl genrsa -out ca-key.pem 2048
	openssl req -x509 -new -nodes -key ca-key.pem -days 365 -out ca.pem -subj "/CN=kube-ca"

api:
	openssl genrsa -out apiserver-key.pem 2048
	openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl-api.cnf
	openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl-api.cnf

worker: worker-0 worker-1 worker-2

worker-0:
	openssl genrsa -out coreos-0-worker-key.pem 2048
	WORKER_IP="200.135.37.93" openssl req -new -key coreos-0-worker-key.pem -out coreos-0-worker.csr -subj "/CN=coreos-0" -config openssl-worker.cnf
	WORKER_IP="200.135.37.93" openssl x509 -req -in coreos-0-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos-0-worker.pem -days 365 -extensions v3_req -extfile openssl-worker.cnf

worker-1:
	openssl genrsa -out coreos-1-worker-key.pem 2048
	WORKER_IP="200.135.37.94" openssl req -new -key coreos-1-worker-key.pem -out coreos-1-worker.csr -subj "/CN=coreos-1" -config openssl-worker.cnf
	WORKER_IP="200.135.37.94" openssl x509 -req -in coreos-1-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos-1-worker.pem -days 365 -extensions v3_req -extfile openssl-worker.cnf

worker-2:
	openssl genrsa -out coreos-2-worker-key.pem 2048
	WORKER_IP="200.135.37.95" openssl req -new -key coreos-2-worker-key.pem -out coreos-2-worker.csr -subj "/CN=coreos-2" -config openssl-worker.cnf
	WORKER_IP="200.135.37.95" openssl x509 -req -in coreos-2-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos-2-worker.pem -days 365 -extensions v3_req -extfile openssl-worker.cnf

admin:
	openssl genrsa -out admin-key.pem 2048
	openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
	openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365
	#openssl pkcs12 -export -in admin.pem -inkey admin-key.pem -out admin.p12
