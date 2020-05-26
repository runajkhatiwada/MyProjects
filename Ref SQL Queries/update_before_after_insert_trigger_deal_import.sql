DECLARE @ixp_rule_id INT

SELECT @ixp_rule_id = ixp_rules_id
FROM ixp_rules
WHERE ixp_rules_name = 'Deals'

UPDATE ixp_rules 
SET before_insert_trigger = '',
	after_insert_trigger = ''
WHERE ixp_rules_id = @ixp_rule_id 

UPDATE ixp_rules
SET before_insert_trigger = '
		UPDATE a
		SET source_system_book_id1 = sb.source_system_book_id,
			source_system_book_id2 = sb1.source_system_book_id,
			source_system_book_id3 = sb2.source_system_book_id,
			source_system_book_id4 = sb3.source_system_book_id
		FROM source_system_book_map s
		INNER JOIN [final_process_table] a
			ON a.sub_book = s.logical_name
		LEFT JOIN source_book sb
			ON sb.source_book_id = s.source_system_book_id1
		LEFT JOIN source_book sb1
			ON sb1.source_book_id = s.source_system_book_id2
		LEFT JOIN source_book sb2
			ON sb2.source_book_id = s.source_system_book_id3
		LEFT JOIN source_book sb3
			ON sb3.source_book_id = s.source_system_book_id4

		EXEC spa_generate_deal_details ''[final_process_table]''
	',
	after_insert_trigger = '
		UPDATE sdh
		SET entire_term_start = t.term_start,
		    entire_term_end = t.term_end
		FROM source_deal_header sdh
		INNER JOIN (
			SELECT MIN(temp.term_start) term_start, 
				   MAX(temp.term_end) term_end,
				   sdh.source_deal_header_id
			FROM source_deal_header sdh
			INNER JOIN [temp_process_table] temp
				ON sdh.deal_id = temp.deal_id
			GROUP BY sdh.source_deal_header_id
		) t ON sdh.source_deal_header_id = t.source_deal_header_id
	'
WHERE ixp_rules_id = @ixp_rule_id