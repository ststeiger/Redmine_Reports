
-- Linked-Server-Sync 

EXEC master.dbo.sp_addlinkedserver 
    @server = N'REMOTEDB'
   ,@srvproduct = 'OLE DB Provider for SQL'
   ,@provider = N'SQLNCLI'
   ,@datasrc = 'REMOTEDB' -- this is the reference, but the actual instance name, e.g.  'CORDB2016\SM, 17666'
   ,@catalog = 'master'

GO

EXEC master.dbo.sp_addlinkedsrvlogin 
    @rmtsrvname = N'REMOTEDB'
   ,@useself = false
   --,@locallogin = 'LocalIntegrationUser'
   ,@locallogin = NULL 
   ,@rmtuser = N'ApertureWebServicesDE'
   ,@rmtpassword = N'TOP_SECRET'
GO

EXEC sp_serveroption @server='REMOTEDB', @optname='rpc', @optvalue='true'
EXEC sp_serveroption @server='REMOTEDB', @optname='rpc out', @optvalue='true'


-- SELECT * FROM REMOTEDB.<DB_NAME>.information_schema.tables 
-- SELECT * FROM REMOTEDB.<DB_NAME>.dbo.<TABLE_NAME>
