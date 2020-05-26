DECLARE @mapping_ids VARCHAR(MAX) = '52,56,57,58,59,111', @sql VARCHAR(MAX)


;WITH CTE1 AS(
	SELECT DISTINCT gmp.user_login_id,
		   asr.role_name,
		   asr.role_id,
		   gmh.mapping_name,
		   gmh.mapping_table_id
	FROM generic_mapping_header gmh 
	LEFT JOIN generic_mapping_privilege gmp
		ON gmh.mapping_table_id = gmp.mapping_table_id
	LEFT JOIN application_security_role asr
		ON asr.role_id = gmp.role_id
)


SELECT MAX(mapping_name) AS [mapping_name],
	   STUFF((SELECT ',' + [user_login_id]
	   		FROM CTE1
	   		WHERE mapping_table_id = C.mapping_table_id
	   		FOR XML PATH ('')), 1, 1, '') AS user_ids, 
	   STUFF((SELECT ',' + CAST(role_name AS VARCHAR(MAX))
	   		FROM CTE1
	   		WHERE mapping_table_id = C.mapping_table_id
	   		FOR XML PATH ('')), 1, 1, '') AS role_names,
	   STUFF((SELECT ',' + CAST(role_id AS VARCHAR(MAX))
	   		FROM CTE1
	   		WHERE mapping_table_id = C.mapping_table_id
	   		FOR XML PATH ('')), 1, 1, '') AS role_ids,
	   
	   MAX(mapping_table_id) AS [mapping_table_id]
FROM CTE1 C
INNER JOIN dbo.SplitCommaSeperatedValues(@mapping_ids) i
	ON i.item = c.mapping_table_id
GROUP BY mapping_table_id
ORDER BY [mapping_name]
