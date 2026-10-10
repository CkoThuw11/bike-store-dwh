IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'meltano_reader')
    CREATE LOGIN meltano_reader WITH PASSWORD = '$(MELTANO_READER_PASSWORD)', DEFAULT_DATABASE = BikeStores, CHECK_POLICY = OFF;
ELSE
BEGIN
    ALTER LOGIN meltano_reader WITH CHECK_POLICY = OFF;
    ALTER LOGIN meltano_reader WITH PASSWORD = '$(MELTANO_READER_PASSWORD)';
END
GO

USE BikeStores;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'meltano_reader')
    CREATE USER meltano_reader FOR LOGIN meltano_reader;

ALTER ROLE db_datareader ADD MEMBER meltano_reader;

-- Lets catalog discovery see primary keys (needed for upsert in target-postgres).
GRANT VIEW DEFINITION TO meltano_reader;
GO
