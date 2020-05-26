DECLARE @app_admin_role_check INT, @user_name VARCHAR(1024)
SET @user_name = dbo.FNADBUSER() 
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@user_name)
	   

SELECT DISTINCT
	   ssbm.book_deal_type_map_id sub_book_id,
	   sub.[entity_name] + ' | ' + stra.[entity_name] + ' | ' + book.[entity_name] + ' | ' + ssbm.logical_name book_structure
FROM source_system_book_map ssbm
INNER JOIN portfolio_hierarchy book 
	ON book.[entity_id] = ssbm.fas_book_id
INNER JOIN portfolio_hierarchy stra 
	ON book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub 
	ON stra.parent_entity_id = sub.[entity_id]
LEFT JOIN application_functional_users afu
	ON ISNULL(afu.entity_id, -3) = ISNULL(sub.entity_id, -3)	
LEFT JOIN application_security_role asr
	ON afu.role_id = asr.role_id
LEFT JOIN application_role_user aru
	ON aru.role_id = asr.role_id
WHERE afu.login_id = @user_name
	OR aru.user_login_id = @user_name
	OR @app_admin_role_check = 1
ORDER BY book_structure

--SELECT *
--FROM portfolio_hierarchy sub 
--INNER JOIN application_functional_users afu
--	ON ISNULL(afu.entity_id, -1) = ISNULL(sub.entity_id, -1)
	
--LEFT JOIN application_security_role asr
--	ON afu.role_id = asr.role_id
--LEFT JOIN application_role_user aru
--	ON aru.role_id = asr.role_id
--WHERE afu.login_id = 'test'--dbo.FNADBUSER() 
--	OR aru.user_login_id = 'test'--dbo.FNADBUSER()