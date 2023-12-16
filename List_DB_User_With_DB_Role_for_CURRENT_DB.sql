
DECLARE @DBROLE SYSNAME ='%'
declare @serverOwner varchar(50)
select @serverOwner=(select top 1 DBA_Name from dbaadmin..tbl_dbalist where isserverowner=1)
SELECT 
(select distinct top 1 local_net_address address from sys.dm_exec_connections where local_net_address is not null and local_net_address like '%10.%') IP,
	@@servername Instance_name,
		DB_Name() as 'Database',
        User_Type = 
           CASE mmbrp.[type] 
           WHEN 'G' THEN 'Windows Group' 
           WHEN 'S' THEN 'SQL User' 
           WHEN 'U' THEN 'Windows User' 
           END,
         Database_User_Name = mmbrp.[name],
         --Login_Name = ul.[name],
         DB_Role = rolp.[name],
		 @serverOwner as 'OWNER'
      FROM sys.database_role_members mmbr, -- The Role OR members associations table
         sys.database_principals rolp,     -- The DB Roles names table
         sys.database_principals mmbrp,    -- The Role members table (database users)
         sys.server_principals ul          -- The Login accounts table
      WHERE Upper (mmbrp.[type]) IN ( 'S', 'U', 'G' )
         -- No need for these system account types
         AND Upper (mmbrp.[name]) NOT IN ('SYS','INFORMATION_SCHEMA')
         AND rolp.[principal_id] = mmbr.[role_principal_id]
         AND mmbrp.[principal_id] = mmbr.[member_principal_id]
         AND ul.[sid] = mmbrp.[sid]
         AND rolp.[name] LIKE '%' + @dbRole + '%'
		 AND mmbrp.[name] not like 'dbo'
		  AND mmbrp.[name] not like '%MS_Policy%'


-- for 5.69 
--DECLARE @DBROLE nvarchar(500)
--SET @DBROLE ='%'



