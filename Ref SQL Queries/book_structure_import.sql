--update #temp_book set [book] = 'test 123', [sub book] = 'test 123' where temp_id = 2
--drop table #temp_book 
--select * from #temp_book
--select * into #temp_book from adiha_process.dbo.ixp_book_structure_0_runaj_072C7448_1E2A_4121_8EE4_CAAA6BCD38E6

DECLARE @xml VARCHAR(MAX), @error_msg VARCHAR(MAX)

SELECT
--@xml = ISNULL(@xml, '') + 
'	<GridRowSubsidiary>	
		' + IIF(sub.entity_name IS NULL, 
					'<GridRow entity_name="' + Subsidiary + '" entity_id="" node_level="4" parent_id="1"/>', 
					''
				) + '
	</GridRowSubsidiary>
	<GridRowStrategy>
		' + IIF(stra.entity_name IS NULL, 
					'<GridRow entity_name="' + Strategy + '" entity_id="' + IIF(sub.entity_name IS NULL, CAST(stra.entity_id AS VARCHAR(10)), '')+ '" node_level="" parent_id="' + IIF(sub.entity_name IS NULL, Subsidiary, CAST(sub.entity_id AS VARCHAR(10))) + '"/>', 
					''
				) + '
	</GridRowStrategy>
	<GridRowBook>
		' + IIF(book.entity_name IS NULL, 
					'<GridRow entity_name="' + Book + '" entity_id="' + IIF(sub.entity_name IS NULL, CAST(book.entity_id AS VARCHAR(10)), '')+ '" parent_id="' + IIF(stra.entity_name IS NULL, Strategy, CAST(stra.entity_id AS VARCHAR(10))) + '"/>', 
					''
				) + ' 
	</GridRowBook>
	<GridRowSubBook>
		' + IIF (ssbm.logical_name IS NULL,
					'<GridRow entity_name="' + [Sub Book] +'" entity_id="' + IIF(sub.entity_name IS NULL, CAST(ssbm.book_deal_type_map_id AS VARCHAR(10)), '')+ '" parent_id="' + IIF(book.entity_name IS NULL, Book, CAST(book.entity_id AS VARCHAR(10))) + '"/>',
					''
				) + '
	</GridRowSubBook>
'--select *
FROM #temp_book bs
LEFT JOIN portfolio_hierarchy sub
	ON sub.entity_name = bs.Subsidiary 
		AND sub.hierarchy_level = 2
LEFT JOIN portfolio_hierarchy stra
	ON stra.entity_name = bs.Strategy 
		AND stra.hierarchy_level = 1
		AND stra.parent_entity_id = sub.entity_id
LEFT JOIN portfolio_hierarchy book
	ON book.entity_name = bs.Book
		AND book.hierarchy_level = 0
		AND book.parent_entity_id = stra.entity_id
LEFT JOIN source_system_book_map ssbm
	ON ssbm.logical_name = bs.[Sub Book]
		AND ssbm.fas_book_id = book.[entity_id]
	
SELECT @xml = '<Root function_id="10101200">
		<GridRowCom>
			<GridRow entity_name="' + a.entity_name + '" entity_id="1"></GridRow>
		</GridRowCom>
		' + REPlACE(@xml, '&', '&amp;') + '</Root>'
FROM portfolio_hierarchy  a
	WHERE [entity_id] = -1
--SELECT @xml
--EXEC spa_setup_simple_book_structure @flag = 'i', @xml = @xml, @error_message = @error_msg OUTPUT

--SELECT @error_msg

