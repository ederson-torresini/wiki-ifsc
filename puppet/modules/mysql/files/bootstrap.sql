SET wsrep_on=OFF;
GRANT ALL ON *.* TO 'wsrep-user'@'%' IDENTIFIED BY 'wsrep-password';
FLUSH PRIVILEGES;
SET wsrep_on=ON;
