

--The script  is to verify the data setup for calculating hourly position .


---Filteration Deals to proceed
declare @deal_header_ids varchar(max)=7770, --'1081,1082,1109,2277',
	@sub_entity_id VARCHAR(500)=null,                 
	@strategy_entity_id VARCHAR(500) = NULL,               
	@book_entity_id VARCHAR(500) = NULL

--End Filtrtation


if OBJECT_ID('tempdb..#books') is not null
drop table #books

if OBJECT_ID('tempdb..#temp_deals_pos') is not null
drop table #temp_deals_pos

--if OBJECT_ID('tempdb..#books') is not null
--	drop table #books

--if OBJECT_ID('tempdb..#books') is not null
--	drop table #books

declare @Sql_Select varchar(max),@baseload_block_define_id int

PRINT 'CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT,fas_deal_type_value_id int)    '
      
CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT,fas_deal_type_value_id int)    

SELECT @baseload_block_define_id = value_id FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data

SET @Sql_Select = 
'   INSERT INTO #books
SELECT DISTINCT book.entity_id,ssbm.source_system_book_id1, ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4 fas_book_id,ssbm.fas_deal_type_value_id
FROM   portfolio_hierarchy book(NOLOCK) INNER JOIN Portfolio_hierarchy stra(NOLOCK)  ON  book.parent_entity_id = stra.entity_id
    INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.entity_id
' 
        
IF @sub_entity_id IS NOT NULL   
SET @Sql_Select = @Sql_Select + ' AND stra.parent_entity_id IN  ( '  + @sub_entity_id + ') '              
IF @strategy_entity_id IS NOT NULL   
SET @Sql_Select = @Sql_Select + ' AND (stra.entity_id IN('  + @strategy_entity_id + ' ))'           
IF @book_entity_id IS NOT NULL   
SET @Sql_Select = @Sql_Select + ' AND (book.entity_id IN('   + @book_entity_id + ')) '   


PRINT ( @Sql_Select)
EXEC ( @Sql_Select)

CREATE  INDEX [IX_Book] ON [#books]([fas_book_id])     


CREATE TABLE #temp_deals_pos (deal_header_id INT,process_status bit,product_id int)

	
SET @Sql_Select='
	INSERT INTO #temp_deals_pos (deal_header_id,process_status,product_id)
	SELECT dh.source_deal_header_id,0,isnull(dh.product_id,4101) product_id 
	FROM source_deal_header dh
		INNER JOIN #books sbm ON dh.source_system_book_id1 = sbm.source_system_book_id1 AND 
			dh.source_system_book_id2 = sbm.source_system_book_id2 AND dh.source_system_book_id3 = sbm.source_system_book_id3 AND 
			dh.source_system_book_id4 = sbm.source_system_book_id4 '
	+CASE WHEN  @deal_header_ids IS NULL THEN '' ELSE ' and dh.source_deal_header_id in ('+@deal_header_ids+')' END


PRINT(@Sql_Select)
EXEC(@Sql_Select)

select 'POS001' RuleID,'Combination (Term Start:'+convert(varchar(10),sdd.term_start,120)+', Curve ID:'+cast(sdd.curve_id as varchar) +', Location ID:'+cast(sdd.location_id as varchar)+') should be unique in Deal Detail' RuleDesc, sdd.source_deal_header_id DealID
from source_deal_detail sdd inner join #temp_deals_pos p on sdd.source_deal_header_id=p.deal_header_id
group by sdd.source_deal_header_id,sdd.term_start,sdd.curve_id,sdd.location_id
having count(1)>1

union all

select 'POS002' RuleID,'Shaped Deals should have value in source_deal_detail_hour for the deal terms:'+convert(varchar(10),sdd.term_start,120) RuleDesc, sdd.source_deal_header_id DealID
from source_deal_detail sdd inner join #temp_deals_pos p on sdd.source_deal_header_id=p.deal_header_id
	inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id and sdh.internal_desk_id=17302
	outer apply
	(
		select top(1) * from source_deal_detail_hour where source_deal_detail_id=sdd.source_deal_detail_id
		and term_date between sdd.term_start and sdd.term_end  
	) s
where s.source_deal_detail_id is null

union all

select  'POS003' RuleID,'No Data found in static_data_value where value_id=12000 (OnPeak).' RuleDesc, null DealID
from ( select max(value_id) value_id  from static_data_value where value_id=12000) b  where b.value_id is null

union all

select  'POS004' RuleID,'No External static data value found in static_data_value for base load that code=Base Load and [TYPE_ID] = 10018.' RuleDesc, null DealID
from (
	 select max(value_id) value_id  from static_data_value where code='Base Load' and [TYPE_ID] = 10018
 ) b  where b.value_id is null

union all

select 'POS005' RuleID,'FAS deal type:'+ sdv.code +' in source book mapping will not calculate position.'  RuleDesc, dh.source_deal_header_id DealID
from source_deal_header dh inner join #temp_deals_pos p on dh.source_deal_header_id=p.deal_header_id
	INNER JOIN #books sbm ON dh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		dh.source_system_book_id2 = sbm.source_system_book_id2 AND dh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		dh.source_system_book_id4 = sbm.source_system_book_id4
		and sbm.fas_deal_type_value_id in (402, 404, 405, 406, 408, 411, 410)
 	left join dbo.static_data_value sdv on  sbm.fas_deal_type_value_id=sdv.value_id

union all

select 'POS006' RuleID,'Hourly block term should be generated for deal term start:'+convert(varchar(10),sdd.term_start,120)
	+', term end:'+convert(varchar(10),sdd.term_end,120)+', Block defination ID:'
	+cast(coalesce(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id) as varchar) RuleDesc, sdd.source_deal_header_id DealID
from source_deal_detail sdd inner join #temp_deals_pos p on sdd.source_deal_header_id=p.deal_header_id
	inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	outer apply
	(
		select top(1) * from hour_block_term where block_define_id=coalesce(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
			and block_type=12000 and term_date between sdd.term_start  and sdd.term_end 
  
	) s
where s.block_define_id is null

union all

select 'POS010' RuleID,'The source_deal_header_template.hourly_position_breakdown column:'+ sdv.code+ ' should be Hourly/30Min/15Min.' RuleDesc
, sdh.source_deal_header_id DealID
from source_deal_header sdh  inner join #temp_deals_pos p on sdh.source_deal_header_id=p.deal_header_id
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	inner join static_data_value sdv on  isnull(sdht.hourly_position_breakdown,982)=sdv.value_id
where isnull(sdht.hourly_position_breakdown,980) not in (982,989,987 )

union all

select 'POS011' RuleID,'Deal Term:'+convert(varchar(10),sdd.term_start,120) +' should be >= Deal Date:'+convert(varchar(10),sdh.deal_date,120) RuleDesc
	, sdd.source_deal_header_id DealID
from source_deal_detail sdd inner join #temp_deals_pos p on sdd.source_deal_header_id=p.deal_header_id
	inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
where sdd.term_start<sdh.deal_date


ORDER BY 1,3

