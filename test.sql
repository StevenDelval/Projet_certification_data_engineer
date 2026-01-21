CREATE USER readonly_api_service WITH PASSWORD 'uizo5278pegiehft5498puiqzgto!!ef!1.ef.pej';

GRANT CONNECT ON DATABASE "databaseDataToExpose" TO readonly_api_service;
GRANT USAGE ON SCHEMA public TO readonly_api_service;
REVOKE CREATE ON SCHEMA public FROM readonly_api_service;

-- Lire toutes les tables sauf users (par défaut)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_api_service;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM readonly_api_service;

-- Lire + écrire uniquement sur "users"
GRANT SELECT, INSERT, UPDATE ON TABLE "users" TO readonly_api_service;
REVOKE DELETE ON TABLE "users" FROM readonly_api_service;

GRANT USAGE, SELECT, UPDATE ON SEQUENCE users_id_seq TO readonly_api_service;