declare @ixp_rules_name varchar(200) = 'REC Certificate'

select distinct ir.ixp_rules_id, ir.ixp_rules_name,it.ixp_tables_name,ic.ixp_columns_name
from ixp_import_data_mapping iidm
inner join ixp_rules ir
	on iidm.ixp_rules_id = ir.ixp_rules_id
inner join ixp_tables it
	on it.ixp_tables_id = iidm.dest_table_id
inner join ixp_columns ic
	on ic.ixp_table_id = it.ixp_tables_id 
where ir.ixp_rules_name = @ixp_rules_name