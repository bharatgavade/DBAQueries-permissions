/*The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages */

--Server level Logins and roles

-- one time script on each instance
-- sample script for rgiicedb instance


--select * from tbl_DBAList
--
--alter table tbl_DBAList
--add isServerOwner tinyint not null default 0
--GO
--update tbl_DBAList set isserverowner=1 where row_id=20

---------- quarterly script

declare @serverOwner varchar(50)
select @serverOwner=(select top 1 DBA_Name from DBAADMIN..tbl_DBAList where isServerOwner=1)

SELECT 
	(select distinct top 1 local_net_address address from sys.dm_exec_connections where local_net_address is not null) IP,
	@@servername Instance_name,
	sp.name AS LoginName,
	sp.type_desc AS LoginType,
	case when sp.is_disabled = 0 then 'ACTIVE' WHEN sp.is_disabled = 1 THEN 'INACTIVE' END AS STATUS,
	case when slog.sysadmin = 0 then 'NO' WHEN slog.sysadmin = 1 THEN 'YES' END AS SysAdmin,
	slog.createdate,
	slog.updatedate
	into #t
FROM sys.server_principals sp JOIN master..syslogins slog
ON sp.sid=slog.sid
WHERE sp.type <> 'R' AND sp.name NOT LIKE '##%' order by slog.createdate


alter table #t
add SQL_login_ownership varchar(50),
Remark varchar(50)


update #t
	set SQL_login_ownership='Nilesh Dhavare'
where LoginName in(
'dbateam',
'NT AUTHORITY\SYSTEM',
'NT SERVICE\AzureWLBackupPluginSvc',
'NT SERVICE\MSSQLSERVER',
'NT SERVICE\SQLSERVERAGENT',
'NT SERVICE\SQLTELEMETRY',
'NT SERVICE\SQLWriter',
'NT SERVICE\Winmgmt',
'RGIXPASAPP\rgiadmin',
'RGIXPASAPP\sqluser',
'RELIANCECAPITAL\rgiclsqlsupport',
'RELIANCEGENERAL\rgiclsqlsupport',
'sqluser',
'mailuser',
'backupuser',
'RELIANCEGENERAL\sa_rgisqlon',
'RELIANCECAPITAL\sa_rgiclsqlservice',
'RELIANCEGENERAL\sa_rgiclsqlservice',
'RELIANCEGENERAL\sa_rgisqlsv',
'BROBOT\sa_rgisqlon',
'BROBOT\sa_rgisqlsv',
'BROBOT\rgiclsqlsupport',
'BROBOT\sa_rgiclsqlservice'
)


update #t
	set SQL_login_ownership=@serverOwner
where SQL_login_ownership is null

select * from #t

drop table #t

--------------------------------Password Policy---------------------------------

--select 
--    @@SERVERNAME as servername, 
--    name, 
--    --IS_SRVROLEMEMBER('sysadmin', name) as SYSADMIN,
--    --type_desc,
--    --create_date,
--    is_policy_checked,
--    is_disabled--,
--    --password_hash,
--    --PWDCOMPARE(name, password_hash) as UsernameAsPassword
--FROM sys.sql_loginss