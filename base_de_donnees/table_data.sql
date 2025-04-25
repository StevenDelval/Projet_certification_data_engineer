-- Table des données météo quotidiennes
CREATE TABLE "TableMeteoQuotidien" (
  "DATE" DATE,
  "LAMBX" INTEGER,
  "LAMBY" INTEGER,
  "PRENEI_Q" REAL,
  "PRELIQ_Q" REAL,
  "T_Q" REAL,
  "FF_Q" REAL,
  "Q_Q" REAL,
  "DLI_Q" REAL,
  "SSI_Q" REAL,
  "HU_Q" REAL,
  "EVAP_Q" REAL,
  "ETP_Q" REAL,
  "PE_Q" REAL,
  "SWI_Q" REAL,
  "DRAINC_Q" REAL,
  "RUNC_Q" REAL,
  "RESR_NEIGE_Q" REAL,
  "RESR_NEIGE6_Q" REAL,
  "HTEURNEIGE_Q" REAL,
  "HTEURNEIGE6_Q" REAL,
  "HTEURNEIGEX_Q" REAL,
  "SNOW_FRAC_Q" REAL,
  "ECOULEMENT_Q" REAL,
  "WG_RACINE_Q" REAL,
  "WGI_RACINE_Q" REAL,
  "TINF_H_Q" REAL,
  "TSUP_H_Q" REAL,
  PRIMARY KEY ("DATE", "LAMBX", "LAMBY")
);

-- Table des points piézométriques
CREATE TABLE "TablePiezoInfo" (
  "code_bss" VARCHAR(100) PRIMARY KEY,
  "urn_bss" VARCHAR(255),
  "LAMBX" INTEGER,
  "LAMBY" INTEGER
);

-- Table des types de mesure
CREATE TABLE "Nature_mesure" (
  "code_nature_mesure" VARCHAR(100) PRIMARY KEY,
  "nom_nature_mesure" VARCHAR(255)
);

-- Table des types de continuité
CREATE TABLE "Continuite" (
  "code_continuite" INTEGER PRIMARY KEY,
  "nom_continuite" VARCHAR(255)
);

-- Table des producteurs
CREATE TABLE "Producteur" (
  "code_producteur" BIGINT PRIMARY KEY,
  "nom_producteur" VARCHAR(255)
);

-- Table des mesures piézométriques quotidiennes
CREATE TABLE "TablePiezoQuotidien" (
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
  FOREIGN KEY ("code_bss") REFERENCES "TablePiezoInfo" ("code_bss"),
  FOREIGN KEY ("code_nature_mesure") REFERENCES "Nature_mesure" ("code_nature_mesure"),
  FOREIGN KEY ("code_continuite") REFERENCES "Continuite" ("code_continuite"),
  FOREIGN KEY ("code_producteur") REFERENCES "Producteur" ("code_producteur")
);

-- Insertion d'exemples dans TablePiezoInfo
INSERT INTO "TablePiezoInfo" ("code_bss","urn_bss", "LAMBX", "LAMBY")
VALUES
  ('00263X0129/PZASA4','test', 6280, 25850),
  ('00026X0040/P1','test', 2019, 2019),
  ('00053X0004/F1','test', 2029, 2029);