
-- Linked-Server-Sync 

DECLARE @sql nvarchar(MAX) 
DECLARE @object_schema nvarchar(255) 
DECLARE @object_name nvarchar(255) 


DECLARE @linked_server nvarchar(255)
DECLARE @linked_db nvarchar(255)
DECLARE @cursor_sql nvarchar(MAX) 

SET @linked_server = N'REDMINE_SERVER' 
SET @linked_db = N'Redmine' 
SET @cursor_sql = N'
SET @object_cursor = CURSOR FAST_FORWARD FOR
(
	SELECT * FROM 
	(
		SELECT TOP 999999999 
			 TABLE_SCHEMA 
			,TABLE_NAME 
		FROM ' + @linked_server + N'.' + @linked_db + N'.INFORMATION_SCHEMA.TABLES 
		WHERE (1=1) 
		-- AND TABLE_TYPE = ''BASE TABLE'' -- we create tables + views all in one 
		AND TABLE_NAME NOT IN (''dtproperties'', ''sysdiagrams'')
		ORDER BY TABLE_SCHEMA, TABLE_NAME
	) AS t 
)

OPEN @object_cursor; ' 



DECLARE @object_cursor CURSOR
EXECUTE SP_EXECUTESQL @cursor_sql,
    N'@linked_db nvarchar(255) 
	, @linked_server nvarchar(255) 
	, @object_cursor CURSOR OUTPUT 
	',
    @linked_db = @linked_db,
    @linked_server = @linked_server,
    @object_cursor = @object_cursor OUTPUT
FETCH NEXT FROM @object_cursor INTO @object_schema, @object_name
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
	FETCH NEXT FROM @object_cursor INTO @object_schema, @object_name
END
CLOSE @object_cursor   
DEALLOCATE @object_cursor
