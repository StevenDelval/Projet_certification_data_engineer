CREATE PROCEDURE DeleteUselessRow
AS
BEGIN
    DELETE FROM CsvControlTable WHERE annee_de_fin < YEAR(GETDATE());
END;

