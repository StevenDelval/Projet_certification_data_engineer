-- Table Localisation
CREATE TABLE IF NOT EXISTS "Localisation" (
  "LAMBX" INTEGER,
  "LAMBY" INTEGER,
  PRIMARY KEY ("LAMBX", "LAMBY")
);

-- Table des données météo quotidiennes
CREATE TABLE IF NOT EXISTS "Meteo" (
  "DATE" DATE,
  "LAMBX" INTEGER,
  "LAMBY" INTEGER,
  "PRENEI" REAL,
  "PRELIQ" REAL,
  "T" REAL,
  "FF" REAL,
  "Q" REAL,
  "DLI" REAL,
  "SSI" REAL,
  "HU" REAL,
  "EVAP" REAL,
  "ETP" REAL,
  "PE" REAL,
  "SWI" REAL,
  "SSWI_10J" REAL,
  "DRAINC" REAL,
  "RUNC" REAL,
  "RESR_NEIGE" REAL,
  "RESR_NEIGE6" REAL,
  "HTEURNEIGE" REAL,
  "HTEURNEIGE6" REAL,
  "HTEURNEIGEX" REAL,
  "SNOW_FRAC" REAL,
  "ECOULEMENT" REAL,
  "WG_RACINE" REAL,
  "WGI_RACINE" REAL,
  "TINF_H" REAL,
  "TSUP_H" REAL,
  PRIMARY KEY ("DATE", "LAMBX", "LAMBY"),
  FOREIGN KEY ("LAMBX", "LAMBY") REFERENCES "Localisation" ("LAMBX", "LAMBY")
);
CREATE INDEX idx_meteo_localisation ON "Meteo"("LAMBX", "LAMBY");
-- Pour les jointures Meteo par date
CREATE INDEX idx_meteo_date ON "Meteo"("DATE");

-- Table des points piézométriques
CREATE TABLE IF NOT EXISTS "Info_nappe" (
  "code_bss" VARCHAR(100) PRIMARY KEY,
  "urn_bss" VARCHAR(255),
  "LAMBX" INTEGER,
  "LAMBY" INTEGER,
  FOREIGN KEY ("LAMBX", "LAMBY") REFERENCES "Localisation" ("LAMBX", "LAMBY")
);
CREATE INDEX idx_piezo_localisation ON "Info_nappe"("LAMBX", "LAMBY");

-- Table des types de mesure
CREATE TABLE IF NOT EXISTS "Nature_mesure" (
  "code_nature_mesure" VARCHAR(100) PRIMARY KEY,
  "nom_nature_mesure" VARCHAR(255)
);

-- Table des types de continuité
CREATE TABLE IF NOT EXISTS "Continuite" (
  "code_continuite" INTEGER PRIMARY KEY,
  "nom_continuite" VARCHAR(255)
);

-- Table des producteurs
CREATE TABLE IF NOT EXISTS "Producteur" (
  "code_producteur" BIGINT PRIMARY KEY,
  "nom_producteur" VARCHAR(255)
);

-- Table des mesures piézométriques quotidiennes
CREATE TABLE IF NOT EXISTS "Nappe" (
  "code_bss" VARCHAR(100),
  "date_mesure" DATE,
  "code_nature_mesure" VARCHAR(100),
  "code_continuite" INTEGER,
  "code_producteur" BIGINT,
  "qualification" VARCHAR(100),
  "statut" VARCHAR(100),
  "mode_obtention" VARCHAR(100),
  "profondeur_nappe" REAL,
  "niveau_nappe_eau" REAL,
  PRIMARY KEY ("code_bss", "date_mesure"),
  FOREIGN KEY ("code_bss") REFERENCES "Info_nappe" ("code_bss"),
  FOREIGN KEY ("code_nature_mesure") REFERENCES "Nature_mesure" ("code_nature_mesure"),
  FOREIGN KEY ("code_continuite") REFERENCES "Continuite" ("code_continuite"),
  FOREIGN KEY ("code_producteur") REFERENCES "Producteur" ("code_producteur")
);
-- Pour les requêtes avec filtres de date
CREATE INDEX idx_nappe_date_mesure ON "Nappe"("date_mesure");

CREATE TABLE IF NOT EXISTS users (
  "id" SERIAL PRIMARY KEY,

  "username" VARCHAR(100) UNIQUE NOT NULL,
  "hashed_password" VARCHAR(255) NOT NULL,

  "first_name" VARCHAR(100) NOT NULL,
  "last_name" VARCHAR(100) NOT NULL,
  "email" VARCHAR(100) UNIQUE NOT NULL,
  "address" VARCHAR(255) NOT NULL,

  -- RGPD : consentement
  "consent_given" BOOLEAN NOT NULL DEFAULT FALSE,
  "consent_date" TIMESTAMPTZ,
  "consent_version" VARCHAR(20),

  -- Cycle de vie RGPD
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  "deleted_at" TIMESTAMPTZ,

  -- Audit
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_login_at" TIMESTAMPTZ
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active);


-- Insertion d'exemples dans Localisation
INSERT INTO "Localisation" ("LAMBX", "LAMBY")
VALUES
  (6280, 25850),
  (5640,26650),
  (5560,26570);

-- Insertion d'exemples dans Info_nappe
INSERT INTO "Info_nappe" ("code_bss","urn_bss", "LAMBX", "LAMBY")
VALUES
  ('00263X0129/PZASA4','test', 6280, 25850),
  ('00026X0040/P1','test', 5640,26650),
  ('00053X0004/F1','test', 5560,26570);