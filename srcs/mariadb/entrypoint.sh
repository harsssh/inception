#!/bin/sh
set -ex

init_db() {
  echo "Initializing database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
  echo "Database initialized successfully"
}

run_temp_mariadb() {
  mariadbd --user=mysql --datadir=/var/lib/mysql &
  sleep 3
}

kill_temp_mariadb() {
  kill $!
  while kill -0 $! 2>/dev/null; do
    sleep 1
  done
}

# TODO: Provide appropriate privileges
# create_user [username] [password]
create_user() {
  # check arguments
  if [ $# -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    echo "Failed to create user: invalid arguments"
    exit 1
  fi
  echo "Creating user '$1'..."
  mariadb -u root <<-EOSQL
		CREATE USER IF NOT EXISTS '$1'@'%' IDENTIFIED BY '$2';
		GRANT ALL PRIVILEGES ON *.* TO '$1'@'%' WITH GRANT OPTION;
		CREATE USER IF NOT EXISTS '$1'@'localhost' IDENTIFIED BY '$2';
		GRANT ALL PRIVILEGES ON *.* TO '$1'@'localhost' WITH GRANT OPTION;
		FLUSH PRIVILEGES;
	EOSQL
  echo "User '$1' created successfully"
}

# create_database [database]
create_database() {
  # check arguments
  if [ $# -ne 1 ] || [ -z "$1" ]; then
    echo "Failed to create database: invalid arguments"
    exit 1
  fi
  echo "Creating database '$1'..."
  mariadb -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS \`$1\`;
	EOSQL
  echo "Database '$1' created successfully"
}

main() {
  init_db
  run_temp_mariadb
  if [ -n "$MARIADB_DATABASE" ]; then
    create_database "$MARIADB_DATABASE"
  fi
  if [ -n "$MARIADB_USER" ] && [ -n "$MARIADB_PASSWORD" ]; then
    create_user "$MARIADB_USER" "$MARIADB_PASSWORD"
  fi
  kill_temp_mariadb

  # Start mariadb
  exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql
}

main
