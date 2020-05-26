SELECT * 
FROM application_ui_template 
WHERE application_function_id = 20007400 --application_ui_template_id = 7454

--template_definition
SELECT * 
FROM application_ui_template_definition 
WHERE application_function_id = 20007400
--insert into application_ui_template_definition (application_function_id,field_id,farrms_field_id,default_label,field_type,data_type,header_detail,system_required,sql_string,is_disable,is_hidden,default_value,insert_required,data_flag,update_required,has_round_option,blank_option,is_primary,is_udf,is_identity)
--values(10164500,'valuation_date','valuation_date','Valuation Date','calendar','date','h','n',NULL,'n','n',NULL,'n','n','n','n','n','n','n','n')
--update application_ui_template_definition set data_type='str' where application_ui_field_id in (77049)
--group
SELECT * 
FROM application_ui_template_group 
WHERE application_ui_template_id = 8850
update application_ui_template_group set active_flag = 'y', default_flag = 'n', field_layout='1C' where application_group_id=15856
--insert into application_ui_template_group (application_ui_template_id, group_name, group_description, active_flag, default_flag, sequence, inputWidth, field_layout, application_grid_id)
--values (8850, 'Types', 'Types', 'n', 'y', 2, null, '1C', null)
--template_field


SELECT * 
FROM application_ui_template_fields a
	INNER JOIN dbo.SplitCommaSeperatedValues(15856) t
		ON a.application_group_id = t.item
update application_ui_template_fields set sequence = 8 where application_field_id=92837
--select * delete from application_ui_template_fields where application_field_id in (77462)
--77045,77046
insert into application_ui_template_fields(application_group_id, application_ui_field_id, application_fieldset_id, field_type, sequence)
select 13939, 77044,null, 'combo',null union all
--select 15856 application_group_id, application_ui_field_id, application_fieldset_id, field_type, case when sequence = 9 then 1 when sequence=10 then 2 end from application_ui_template_fields where application_ui_field_id in (
--77045,
--77046)
--15856,13939
--layout
SELECT a.* 
FROM application_ui_layout_grid a
	INNER JOIN dbo.SplitCommaSeperatedValues(15856) t
		ON a.group_id = t.item
	LEFT JOIN adiha_grid_definition ag
		ON ISNULL(NULLIF( a.grid_id, 'form'), -1)  =  ag.grid_id
update application_ui_layout_grid set layout_cell='a' where application_ui_layout_grid_id = 13760
insert into application_ui_layout_grid (group_id, layout_cell, grid_id, sequence)
values (15856, 'b', 425, 2)

--fieldset 
SELECT a.* 
FROM application_ui_template_fieldsets a
	INNER JOIN dbo.SplitCommaSeperatedValues(8387) t
		ON a.application_group_id = t.item
update application_ui_template_fieldsets set width = 750, num_column = 3 where application_fieldset_id in (
3304,
3305,
3306
)


insert into application_ui_template_fieldsets (application_group_id, fieldset_name, is_disable, is_hidden, inputLeft, inputTop, label, width, num_column)
select 9523, 'destination', 'n', 'n', null, null, 'Destination', 200, 2 

SELECT * FROM application_ui_filter where application_ui_filter_id in (210,211)
SELECT * FROM application_ui_filter_details where application_ui_filter_id in (210,211)

exec spa_application_ui_export '10164500'

select * from sys.objects where name like '%export%' and type='p'

spa_adiha_grid_definition_export 'deal_detail_cost'

EXEC spa_create_application_ui_json 'j', '10164500', 'RemitSubmission', NULL

