SELECT * FROM report_tablix_column WHERE tablix_id  = 20014--alias = 'Transaction To Be Cleared'
SELECT * FROM report_tablix_header WHERE tablix_id  = 20014
update report_tablix_header 
set font = 'Tahoma',font_size=8,font_style='1,0,0',text_align='Left',background='#458bc1',text_color='#ffffff'
 WHERE tablix_id  = 20014

--INSERT INTO report_tablix_column (tablix_id, column_id, placement, alias, sortable, font, font_size, font_style, text_align, text_color, background, dataset_id, column_order, custom_field, render_as, column_template, cross_summary_aggregation)
SELECT DISTINCT 19980 tablix_id, data_source_column_id, 1 placement, alias, 1 sortable, 'Tahoma' font, 8 font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 23360 dataset_id, (ROW_NUMBER() OVER (ORDER BY alias)+4) column_order, 0 custom_field, 0 render_as, -1 column_template, -1 cross_summary_aggregation
FROM data_source_column
WHERE source_id = 2850 
	AND data_source_column_id  IN (23151)

--INSERT INTO report_tablix_header (tablix_id, column_id, font, font_style, text_align, text_color, background, report_tablix_column_id)
select tablix_id, column_id, font, '1,0,0' font_style, text_align, text_color, background, report_tablix_column_id
from report_tablix_column a
inner join data_source_column b on a.column_id = b.data_source_column_id
WHERE source_id = 2850 
order by 8