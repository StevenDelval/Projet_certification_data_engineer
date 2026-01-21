CREATE USER ${username} WITH PASSWORD '${password}';

GRANT CONNECT ON DATABASE "databaseDataToExpose" TO ${username};
GRANT USAGE ON SCHEMA public TO ${username};
REVOKE CREATE ON SCHEMA public FROM ${username};

-- Lire toutes les tables sauf users (par défaut)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${username};
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM ${username};

-- Lire + écrire uniquement sur "users"
GRANT SELECT, INSERT, UPDATE ON TABLE "users" TO ${username};
REVOKE DELETE ON TABLE "users" FROM ${username};

GRANT USAGE, SELECT, UPDATE ON SEQUENCE users_id_seq TO ${username};