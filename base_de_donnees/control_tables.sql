CREATE TABLE  CsvControlTable (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    nom_du_fichier NVARCHAR(100),
    url_du_fichier NVARCHAR(200),
    annee_de_fin INT
);

INSERT INTO CsvControlTable (nom_du_fichier, url_du_fichier, annee_de_fin)
    VALUES
    ('QUOT_SIM2_2000-2009.parquet', 'https://www.data.gouv.fr/fr/datasets/r/10d2ce77-5c3b-44f8-bb46-4df27ed48595', 2009),
    ('QUOT_SIM2_2010-2019.parquet', 'https://www.data.gouv.fr/fr/datasets/r/da6cd598-498b-4e39-96ea-fae89a4a8a46', 2019),
    ('QUOT_SIM2_2020-2029.parquet', 'https://www.data.gouv.fr/fr/datasets/r/92065ec0-ea6f-4f5e-8827-4344179c0a7f', 2029);

CREATE TABLE ApiControlTable (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    code_bss NVARCHAR(100) UNIQUE,
    date_debut_mesure DATE
);

INSERT INTO ApiControlTable (code_bss, date_debut_mesure)
    VALUES
    ('00263X0129/PZASA4', '2000-01-01'),
    ('00026X0040/P1', '2000-01-01'),
    ('00053X0004/F1', '2000-01-01'),
    ('00057X0005/F3', '2000-01-01');
