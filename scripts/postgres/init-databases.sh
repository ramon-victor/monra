#!/bin/sh
set -eu

: "${MONRA_STUDIO_DB_PASSWORD:?MONRA_STUDIO_DB_PASSWORD is required}"
: "${MONRA_WA_DB_PASSWORD:?MONRA_WA_DB_PASSWORD is required}"

psql --set=ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --set=studio_password="$MONRA_STUDIO_DB_PASSWORD" \
  --set=wa_password="$MONRA_WA_DB_PASSWORD" <<-'SQL'
	SELECT format('CREATE ROLE monra_studio LOGIN PASSWORD %L', :'studio_password')
	WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'monra_studio') \gexec
	ALTER ROLE monra_studio PASSWORD :'studio_password';

	SELECT format('CREATE ROLE monra_wa LOGIN PASSWORD %L', :'wa_password')
	WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'monra_wa') \gexec
	ALTER ROLE monra_wa PASSWORD :'wa_password';

	SELECT 'CREATE DATABASE monra_studio OWNER monra_studio'
	WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'monra_studio') \gexec
	SELECT 'CREATE DATABASE monra_wa_auth OWNER monra_wa'
	WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'monra_wa_auth') \gexec
	SELECT 'CREATE DATABASE monra_wa_users OWNER monra_wa'
	WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'monra_wa_users') \gexec
SQL

for database in monra_studio monra_wa_auth monra_wa_users; do
  owner=monra_wa
  if [ "$database" = "monra_studio" ]; then
    owner=monra_studio
  fi

  psql --set=ON_ERROR_STOP=1 \
    --username "$POSTGRES_USER" \
    --dbname "$database" \
    --set=database_owner="$owner" <<-'SQL'
	REVOKE CREATE ON SCHEMA public FROM PUBLIC;
	GRANT ALL ON SCHEMA public TO :"database_owner";
SQL
done
