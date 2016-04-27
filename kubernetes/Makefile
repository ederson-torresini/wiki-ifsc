all: clean ca api worker admin

clean:
	rm -f *.key *.srl *.csr *.pem

ca:
	openssl genrsa -out ca-key.pem 2048
	openssl req -x509 -new -nodes -key ca-key.pem -days 365 -out ca.pem -subj "/CN=kube-ca"

api:
	openssl genrsa -out apiserver-key.pem 2048
	openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl-api.cnf
	openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl-api.cnf

worker: worker-100 worker-101

worker-100:
	openssl genrsa -out coreos-0-worker-key.pem 2048
	WORKER_IP="172.18.110.100" openssl req -new -key coreos-0-worker-key.pem -out coreos-0-worker.csr -subj "/CN=coreos-0" -config openssl-worker.cnf
	WORKER_IP="172.18.110.100" openssl x509 -req -in coreos-0-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos-0-worker.pem -days 365 -extensions v3_req -extfile openssl-worker.cnf

worker-101:
	openssl genrsa -out coreos-1-worker-key.pem 2048
	WORKER_IP="172.18.110.101" openssl req -new -key coreos-1-worker-key.pem -out coreos-1-worker.csr -subj "/CN=coreos-1" -config openssl-worker.cnf
	WORKER_IP="172.18.110.101" openssl x509 -req -in coreos-1-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos-1-worker.pem -days 365 -extensions v3_req -extfile openssl-worker.cnf

admin:
	openssl genrsa -out admin-key.pem 2048
	openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
	openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365
