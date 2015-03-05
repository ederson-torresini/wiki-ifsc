INSERT IGNORE INTO mysql.user (Host,User) VALUES ('%','haproxy');
FLUSH PRIVILEGES;
