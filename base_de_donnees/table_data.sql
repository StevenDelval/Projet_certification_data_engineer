CREATE TABLE TableMeteoQuotidien (
  LAMBX INT,
  LAMBY INT,
  DATE DATE,
  PRENEI_Q FLOAT,
  PRELIQ_Q FLOAT,
  T_Q FLOAT,
  FF_Q FLOAT,
  Q_Q FLOAT,
  DLI_Q FLOAT,
  SSI_Q FLOAT,
  HU_Q FLOAT,
  EVAP_Q FLOAT,
  ETP_Q FLOAT,
  PE_Q FLOAT,
  SWI_Q FLOAT,
  DRAINC_Q FLOAT,
  RUNC_Q FLOAT,
  RESR_NEIGE_Q FLOAT,
  RESR_NEIGE6_Q FLOAT,
  HTEURNEIGE_Q FLOAT,
  HTEURNEIGE6_Q FLOAT,
  HTEURNEIGEX_Q FLOAT,
  SNOW_FRAC_Q FLOAT,
  ECOULEMENT_Q FLOAT,
  WG_RACINE_Q FLOAT,
  WGI_RACINE_Q FLOAT,
  TINF_H_Q FLOAT,
  TSUP_H_Q FLOAT
  PRIMARY KEY (LAMBX, LAMBY, DATE) 
);

CREATE TABLE TablePiezoInfo (
  code_bss NVARCHAR(100) PRIMARY KEY,
  LAMBX INT,
  LAMBY INT
);

CREATE TABLE TablePiezoQuotidien (
  code_bss NVARCHAR(100) REFERENCES TablePiezoInfo(code_bss),
  urn_bss NVARCHAR(255),
  date_mesure DATE,
  niveau_nappe_eau FLOAT,
  mode_obtention NVARCHAR(100),
  statut NVARCHAR(100),
  qualification NVARCHAR(100),
  code_continuite NVARCHAR(100),
  nom_continuite NVARCHAR(100),
  code_producteur NVARCHAR(100),
  nom_producteur NVARCHAR(100),
  code_nature_mesure NVARCHAR(100),
  nom_nature_mesure NVARCHAR(100),
  profondeur_nappe FLOAT,
  PRIMARY KEY (code_bss, date_mesure)
);

INSERT INTO TablePiezoInfo (code_bss, LAMBX, LAMBY)
    VALUES
    ('00263X0129/PZASA4', 2009, 2009),
    ('00026X0040/P1', 2019, 2019),
    ('00057X0005/F3', 1999, 1999),
    ('00053X0004/F1', 2029, 2029);

    



