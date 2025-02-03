create user 'repl'@'%' identified by 'pass';
grant replication slave on *.* to 'repl'@'%';
flush privileges;
