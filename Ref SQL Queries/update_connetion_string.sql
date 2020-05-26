EXEC [spa_deploy_rdl_using_clr] 'Trade Export Audit Report_Trade Export Audit Report','Generated Trade Export Audit Report_Trade Export Audit Report via SQL Job' ,''
UPDATE connection_string
 SET 
  report_server_url = 'http://psdl12/ReportServer_INSTANCE2016'	-- Report Server URL
 , report_server_domain = 'psdl12'						-- Domain of the proxy user used to connect Report Server
 , report_server_user_name = 'dpcs\rkhatiwada'					-- Proxy user used to connect Report Server
 , report_server_password = dbo.[FNAEncrypt]('runaj')		-- Password of proxy user
 , report_server_datasource_name = 'TRMTracker_ACT'	-- Datasource name created in Report Server. Highly recommended    to match with database name
, report_server_target_folder = 'TRMTracker_ACT'	-- Target folder in Report Server to deploy RDL files. Highly recommended to match with database name
, file_attachment_path = 'http://sjdev01.farrms.us/TRMTracker_ACT/trm/adiha.php.scripts/adiha_pm_html/process_controls/clientImageFile.jpg' -- Web url to logo image
, document_path = '\\PSDL12\shared_docs2'	 -- Shared network path to shared_docs folder in application


SELECT *
FROM connection_string
