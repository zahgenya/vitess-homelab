# Copyright 2022 The Vitess Authors.
# Licensed under the Apache License, Version 2.0

##############################################################################
# Equivalent of mysql_secure_installation
##############################################################################

# Changes during the init db should not make it to the binlog.
# They could potentially create errant transactions on replicas.
SET @original_super_read_only=IF(@@global.super_read_only=1, 'ON', 'OFF');
SET GLOBAL super_read_only='OFF';
SET sql_log_bin = 0;

# Remove anonymous users.
DELETE FROM mysql.user WHERE User = '';

# Disable remote root access (only allow UNIX socket).
DELETE FROM mysql.user WHERE User = 'root' AND Host != 'localhost';

# Remove test database.
DROP DATABASE IF EXISTS test;

##############################################################################
# Vitess-specific users
##############################################################################

CREATE USER 'vt_dba'@'localhost';
GRANT ALL ON *.* TO 'vt_dba'@'localhost';
GRANT GRANT OPTION ON *.* TO 'vt_dba'@'localhost';

CREATE USER 'vt_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO `vt_app`@`localhost`;

CREATE USER 'vt_appdebug'@'localhost';
GRANT SELECT, SHOW DATABASES, PROCESS ON *.* TO 'vt_appdebug'@'localhost';

CREATE USER 'vt_allprivs'@'localhost';
GRANT ALL ON *.* TO 'vt_allprivs'@'localhost';

CREATE USER 'vt_repl'@'%';
GRANT REPLICATION SLAVE ON *.* TO 'vt_repl'@'%';

CREATE USER 'vt_filtered'@'localhost';
GRANT ALL ON *.* TO 'vt_filtered'@'localhost';

FLUSH PRIVILEGES;

RESET REPLICA ALL;
RESET BINARY LOGS AND GTIDS;
SET GLOBAL super_read_only=IFNULL(@original_super_read_only, 'ON');
