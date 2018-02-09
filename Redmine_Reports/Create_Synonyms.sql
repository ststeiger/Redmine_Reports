
-- Linked-Server-Sync 

DECLARE @sql nvarchar(MAX) 
DECLARE @object_schema nvarchar(256) 
DECLARE @object_name nvarchar(256) 
DECLARE @linked_server nvarchar(256) 
DECLARE @linked_db nvarchar(256) 

SET @linked_server = 'REDMINE_SERVER' 
SET @linked_db = 'Redmine'

DECLARE object_cursor CURSOR FOR 
(
	SELECT * FROM 
	(
		SELECT TOP 999999999 
			 TABLE_SCHEMA 
			,TABLE_NAME 
		FROM REDMINE_SERVER.Redmine.INFORMATION_SCHEMA.TABLES 
		WHERE (1=1) 
		-- AND TABLE_TYPE = 'BASE TABLE' we create tables + views all in one 
		AND TABLE_NAME NOT IN ('dtproperties', 'sysdiagrams')
		ORDER BY TABLE_SCHEMA, TABLE_NAME
	) AS t 
)
OPEN object_cursor   
FETCH NEXT FROM object_cursor INTO @object_schema, @object_name 

WHILE @@FETCH_STATUS = 0   
BEGIN 
	PRINT QUOTENAME(@object_schema) + '.' + QUOTENAME(@object_name) 
	-- TODO: Create schema if not exists 

	SET @sql = N'
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = ''' + REPLACE(@object_name, '''', '''''') + ''')
DROP SYNONYM ' + QUOTENAME(@object_schema) + N'.' + QUOTENAME(@object_name) + N';
' ;
	PRINT @sql 
	EXECUTE(@sql);

	SET @sql = N'
CREATE SYNONYM ' + QUOTENAME(@object_schema) + N'.' + QUOTENAME(@object_name) + N' 
FOR ' + QUOTENAME(@linked_server) + N'.' + QUOTENAME(@linked_db) + '.' + QUOTENAME(@object_schema) + '.' + QUOTENAME(@object_name) + '; 
' ;

	PRINT @sql 
	EXECUTE(@sql);
	FETCH NEXT FROM object_cursor INTO @object_schema, @object_name 
END   

CLOSE object_cursor   
DEALLOCATE object_cursor

-- SELECT * FROM sys.synonyms 
