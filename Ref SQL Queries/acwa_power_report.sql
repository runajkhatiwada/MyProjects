SET ANSI_WARNINGS OFF;  
SET NOCOUNT ON
DECLARE
 @_summary_option CHAR(6)='h', --  'd' Detail, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
 @_sub_id varchar(1000)=null, 
 @_stra_id varchar(1000)=null,
 @_book_id varchar(1000)=null,
 @_subbook_id varchar(1000)=null,
 @_as_of_date VARCHAR(100)=NULL,--'2017-08-01',
 @_source_deal_header_id varchar(1000)=NULL, --=2290,
 @_period_from varchar(6)=null,
 @_period_to varchar(6)=null,
 @_tenor_option varchar(6)='a',
 @_location_id varchar(1000)=null,
 @_curve_id varchar(1000)=null,
 @_commodity_id varchar(8)=NULL,
 @_physical_financial_flag varchar(6)=null,
 @_deal_id varchar(1000)=NULL,
 @_location_group_id  varchar(1000)=null,
 @_grid varchar(1000)=null,
 @_country varchar(1000)=null,
 @_region varchar(1000)=null,
 @_province varchar(1000)=null,
 @_deal_status varchar(8)=null,
 @_confirm_status varchar(8)=null,
 @_profile varchar(8)=null,
 @_term_start VARCHAR(100)=NULL,
 @_term_end VARCHAR(100)=NULL,
 @_deal_type varchar(8)=null,
 @_deal_sub_type varchar(8)=null,
 @_buy_sell_flag varchar(6)=null,
 @_counterparty VARCHAR(MAX)=NULL,  
 @_hour_from varchar(6)=null,
 @_hour_to varchar(6)=null,
 @_block_group varchar(10)=null,
 @_parent_counterparty VARCHAR(10) = NULL,
 @_deal_date_from  VARCHAR(100)=Null,
 @_deal_date_to  VARCHAR(100)=Null,
 @_block_type_group_id  VARCHAR(100)=Null,
 @_trader_id  VARCHAR(100)=Null,
 @_holiday_calendar_id VARCHAR(100)=NULL

--set @_summary_option = nullif( isnull(@_summary_option,nullif('@summary_option', replace('@_summary_option','@_','@'))),'null')
--set	@_sub_id = nullif(  isnull(@_sub_id,nullif('@sub_id', replace('@_sub_id','@_','@'))),'null')
--set	@_stra_id = nullif(  isnull(@_stra_id,nullif('@stra_id', replace('@_stra_id','@_','@'))),'null')
--set @_book_id = nullif(  isnull(@_book_id,nullif('@book_id', replace('@_book_id','@_','@'))),'null')
--set @_subbook_id = nullif(  isnull(@_subbook_id,nullif('@sub_book_id', replace('@_sub_book_id','@_','@'))),'null')
--set @_as_of_date = nullif(  isnull(@_as_of_date,nullif('@as_of_date', replace('@_as_of_date','@_','@'))),'null')
--set @_source_deal_header_id = nullif(  isnull(@_source_deal_header_id,nullif('@source_deal_header_id', replace('@_source_deal_header_id','@_','@'))),'null')
--set @_period_from = nullif(  isnull(@_period_from,nullif('@period_from', replace('@_period_from','@_','@'))),'null')
--set @_period_to = nullif(  isnull(@_period_to,nullif('@period_to', replace('@_period_to','@_','@'))),'null')
--set @_tenor_option = nullif(  isnull(@_tenor_option,nullif('@tenor_option', replace('@_tenor_option','@_','@'))),'null')
--set @_location_id = nullif(  isnull(@_location_id,nullif('@location_id', replace('@_location_id','@_','@'))),'null')
--set @_curve_id = nullif(  isnull(@_curve_id,nullif('@index_id', replace('@_index_id','@_','@'))),'null')
--set @_commodity_id = nullif(  isnull(@_commodity_id,nullif('@commodity_id', replace('@_commodity_id','@_','@'))),'null')
--set @_physical_financial_flag = nullif(  isnull(@_physical_financial_flag,nullif('@physical_financial_flag', replace('@_physical_financial_flag','@_','@'))),'null')
--set @_location_group_id = nullif(  isnull(@_location_group_id,nullif('@location_group_id', replace('@_location_group_id','@_','@'))),'null')
--set @_grid = nullif(  isnull(@_grid,nullif('@grid_id', replace('@_grid_id','@_','@'))),'null')
--set @_country = nullif(  isnull(@_country,nullif('@country_id', replace('@_country_id','@_','@'))),'null')
--set @_region = nullif(  isnull(@_region,nullif('@region_id', replace('@_region_id','@_','@'))),'null')
--set @_province = nullif(  isnull(@_province,nullif('@province_id', replace('@_province_id','@_','@'))),'null')
--set @_deal_status = nullif(  isnull(@_deal_status,nullif('@deal_status_id', replace('@_deal_status_id','@_','@'))),'null')
--set @_confirm_status = nullif(  isnull(@_confirm_status,nullif('@confirm_status_id', replace('@_confirm_status_id','@_','@'))),'null')
--set @_profile = nullif(  isnull(@_profile,nullif('@profile_id', replace('@_profile_id','@_','@'))),'null')
--set @_term_start = nullif(  isnull(@_term_start,nullif('@term_start', replace('@_term_start','@_','@'))),'null')
--set @_term_end = nullif(  isnull(@_term_end,nullif('@term_end', replace('@_term_end','@_','@'))),'null')
--set @_deal_type = nullif(  isnull(@_deal_type,nullif('@deal_type_id', replace('@_deal_type_id','@_','@'))),'null')
--set @_deal_sub_type = nullif(  isnull(@_deal_sub_type,nullif('@deal_sub_type_id', replace('@_deal_sub_type_id','@_','@'))),'null')
--set @_buy_sell_flag = nullif(  isnull(@_buy_sell_flag,nullif('@buy_sell_flag', replace('@_buy_sell_flag','@_','@'))),'null')
--set @_counterparty = nullif(  isnull(@_counterparty,nullif('@counterparty_id', replace('@_counterparty_id','@_','@'))),'null')
--set @_hour_from = nullif(  isnull(@_hour_from,nullif('@hour_from', replace('@_hour_from','@_','@'))),'null')
--set @_hour_to = nullif(  isnull(@_hour_to,nullif('@hour_to', replace('@_hour_to','@_','@'))),'null')

--set @_block_group = nullif(isnull(@_block_group,nullif('@block_group', replace('@_block_group','@_','@'))),'null')
--set @_parent_counterparty = nullif(  isnull(@_parent_counterparty,nullif('@parent_counterparty', replace('@_parent_counterparty','@_','@'))),'null')
--set @_deal_date_from = nullif(  isnull(@_deal_date_from,nullif('@deal_date_from', replace('@_deal_date_from','@_','@'))),'null')
--set @_deal_date_to = nullif(  isnull(@_deal_date_to,nullif('@deal_date_to', replace('@_deal_date_to','@_','@'))),'null')
--set @_block_type_group_id = nullif(  isnull(@_block_type_group_id,nullif('@block_type_group_id', replace('@_block_type_group_id','@_','@'))),'null')
--set @_deal_id = nullif(  isnull(@_deal_id,nullif('@deal_id', replace('@_deal_id','@_','@'))),'null')
--set @_trader_id = nullif(  isnull(@_trader_id,nullif('@trader_id', replace('@_trader_id','@_','@'))),'null')
--set @_holiday_calendar_id = nullif(  isnull(@_holiday_calendar_id,nullif('@holiday_calendar_id', replace('@_holiday_calendar_id','@_','@'))),'null')


declare
	@_format_option CHAR(5)	='r',
	@_group_by CHAR(5)='i' , -- 'i'- Index, 'l' - Location   
	@_round_value CHAR(5) ='8',
	@_convert_uom INT=null,
	@_col_7_to_6 VARCHAR(5)='n',
	@_include_no_breakdown varCHAR(5)='n' 

	,@_sql_select VARCHAR(MAX)        
	,@_report_type INT   
	,@_storage_inventory_sub_type_id INT  
	,@_sel_sql VARCHAR(1000)  
	,@_group_sql VARCHAR(200)           
	,@_block_sql VARCHAR(100)  
	,@_col_name VARCHAR(100)  
	,@_frequency VARCHAR(100)  
	,@_term_END_parameter VARCHAR(100)  
	,@_term_start_parameter VARCHAR(100)  
	,@_actual_summary_option     CHAR(5)  
	,@_hour_pivot_table          VARCHAR(100)
	,@_position_deal varchar(250) ,@_position_no_breakdown varchar(250)
	,@_remain_month VARCHAR(1000)
	,@_column_level              VARCHAR(100)
	,@_temp_process_id           VARCHAR(100)


if object_id('tempdb..#temp_deals') is not null drop table #temp_deals
if object_id('tempdb..#term_date') is not null drop table #term_date
if object_id('tempdb..#minute_break') is not null drop table #minute_break
if object_id('tempdb..#books') is not null DROP TABLE #books
if object_id('tempdb..#tmp_pos_detail_gas') is not null DROP TABLE #tmp_pos_detail_gas
if object_id('tempdb..#tmp_pos_detail_power') is not null DROP TABLE #tmp_pos_detail_power


---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @_sqry2  VARCHAR(MAX)

DECLARE @_user_login_id     VARCHAR(50), @_proxy_curve_view  CHAR(5),@_hypo_breakdown VARCHAR(MAX)
	,@_hypo_breakdown1 VARCHAR(MAX) ,@_hypo_breakdown2 VARCHAR(MAX),@_hypo_breakdown3 VARCHAR(MAX)
	
DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)


DECLARE @_view_nameq VARCHAR(100),@_volume_clm VARCHAR(MAX),@_view_name1 VARCHAR(100)
DECLARE @_dst_column VARCHAR(2000),@_vol_multiplier VARCHAR(2000) ,@_rhpb VARCHAR(MAX)
	,@_rhpb1 VARCHAR(MAX) ,@_rhpb2 VARCHAR(MAX),@_rhpb3 VARCHAR(MAX)
	,@_sqry  VARCHAR(MAX),@_scrt varchar(max) ,@_sqry1  VARCHAR(MAX)
	,@_rpn VARCHAR(MAX)
	,@_rpn1 VARCHAR(MAX) ,@_rpn2 VARCHAR(MAX),@_rpn3 VARCHAR(MAX)

declare @_commodity_str varchar(max),@_rhpb_0 varchar(max),@_commodity_str1 varchar(max)

declare @_std_whatif_deals varchar(250)  ,@_hypo_deal_header varchar(250), @_hypo_deal_detail varchar(250),@_position_hypo varchar(250)--, @_position_breakdown varchar(250)

SET @_temp_process_id=dbo.FNAGetNewID()
SET @_user_login_id = dbo.FNADBUser() 

declare @_region_id varchar(3)

SELECT @_region_id =  cast(case region_id
						 WHEN 1 THEN  101
						 WHEN 3 THEN  110
						 WHEN 2 THEN 103
						 WHEN 5 THEN 104
						 WHEN 4 THEN 105
						 ELSE 120
					END as varchar)
FROM   application_users	WHERE  user_login_id = @_user_login_id 

-- If group by proxy curvem set group by ='l' and assign another variable
SET @_proxy_curve_view = 'n'

IF @_group_by = 'p'
BEGIN
	SET @_group_by = 'i'
	SET @_proxy_curve_view = 'y'
END

SET @_hour_pivot_table=dbo.FNAProcessTableName('hour_pivot', @_user_login_id,@_temp_process_id)  
SET @_position_deal=dbo.FNAProcessTableName('position_deal', @_user_login_id,@_temp_process_id)  
SET @_position_no_breakdown=dbo.FNAProcessTableName('position_no_breakdown', @_user_login_id,@_temp_process_id)  

--SET @_position_breakdown=dbo.FNAProcessTableName('position_breakdown', @_user_login_id,@_temp_process_id)  

SET @_baseload_block_type = '12000'	-- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data


IF @_baseload_block_define_id IS NULL 
	SET @_baseload_block_define_id = 'NULL'


IF @_hour_from IS NOT NULL
BEGIN
	IF @_hour_to IS NULL
		SET @_hour_to=@_hour_from
END	
ELSE
BEGIN
	IF @_hour_to IS NOT NULL
		SET @_hour_from= @_hour_to
END


IF NULLIF(@_format_option,'') IS NULL
	SET @_format_option='c'
	

DECLARE @_term_start_temp datetime,@_term_END_temp datetime  
 
CREATE TABLE #temp_deals ( source_deal_header_id int)



IF nullif(@_period_from,'1900') IS NOT NULL  
BEGIN   
--	select  dbo.FNAGetTermStartDate('m', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_from as int))
	SET  @_term_start_temp= dbo.FNAGetTermStartDate('m', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_from as int))
END  


IF nullif(@_period_to,'1900') IS NOT NULL  
BEGIN  

--print convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01'
---select dbo.FNAGetTermStartDate('m',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_to as int)+1)
	
	SET  @_term_END_temp = dbo.FNAGetTermStartDate('m',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_to as int)+1)
	
	set @_term_END_temp=dateadd(DAY,-1,@_term_END_temp)
	
END  


SET @_term_start=convert(VARCHAR(100),isnull(@_term_start_temp ,@_term_start),120)
SET @_term_end=convert(VARCHAR(100),isnull(@_term_END_temp ,@_term_end),120)

--select @_term_start,@_term_end

IF @_term_start IS NOT NULL AND @_term_END IS NULL              
	SET @_term_END = @_term_start   
	           
IF @_term_start IS NULL AND @_term_END IS NOT NULL              
	SET @_term_start = @_term_END       	  
  
IF @_deal_date_from IS NOT NULL AND @_deal_date_to IS NULL              
	SET @_deal_date_to = @_deal_date_from  
	            
IF @_deal_date_from IS NULL AND @_deal_date_to IS NOT NULL              
	SET @_deal_date_from = @_deal_date_to  
   
 
----print 'CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    '
      
CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    

SET @_Sql_Select = 
'   INSERT INTO #books
    SELECT DISTINCT book.entity_id,
           ssbm.source_system_book_id1,
           ssbm.source_system_book_id2,
           ssbm.source_system_book_id3,
           ssbm.source_system_book_id4 fas_book_id
    FROM   portfolio_hierarchy book(NOLOCK)
           INNER JOIN Portfolio_hierarchy stra(NOLOCK)
                ON  book.parent_entity_id = stra.entity_id
           INNER JOIN source_system_book_map ssbm
                ON  ssbm.fas_book_id = book.entity_id
    WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)  ' 
        
IF @_sub_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND stra.parent_entity_id IN  ( '+ @_sub_id + ') '              
IF @_stra_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND (stra.entity_id IN('  + @_stra_id + ' ))'           
IF @_book_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND (book.entity_id IN('   + @_book_id + ')) '   
IF @_subbook_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + ' AND ssbm.book_deal_type_map_id IN (' + @_subbook_id + ' ) '

----print ( @_Sql_Select)    
EXEC ( @_Sql_Select)    

CREATE  INDEX [IX_Book] ON [#books]([fas_book_id])                    


SET @_Sql_Select = '
	insert into #temp_deals(source_deal_header_id) select sdh.source_deal_header_id from dbo.source_deal_header sdh 
	inner join #books b on sdh.source_system_book_id1=b.source_system_book_id1 and sdh.source_system_book_id2=b.source_system_book_id2 
		and sdh.source_system_book_id3=b.source_system_book_id3 and sdh.source_system_book_id4=b.source_system_book_id4
	where 1=1 '
		+case when @_source_deal_header_id is not null then ' and sdh.source_deal_header_id in ('+@_source_deal_header_id+')' else '' end
		+case when @_deal_id is not null then ' and sdh.deal_id LIKE ''%' + @_deal_id + '%''' else '' end
		+case when @_confirm_status is not null then ' and sdh.confirm_status_type in ('+@_confirm_status+')' else '' end
		+case when @_profile is not null then ' and sdh.internal_desk_id in ('+@_profile+')' else '' end
		+case when @_deal_type is not null then ' and sdh.source_deal_type_id ='+@_deal_type else '' end
		+case when @_deal_sub_type is not null then ' and sdh.deal_sub_type_type_id ='+@_deal_sub_type else '' end
		+CASE WHEN @_counterparty IS NOT NULL THEN ' AND sdh.counterparty_id IN (' + @_counterparty + ')'ELSE '' END
		+CASE WHEN @_trader_id IS NOT NULL THEN ' AND sdh.trader_id IN (' + @_trader_id + ')'ELSE '' END
		+CASE WHEN @_deal_status IS NOT NULL THEN ' AND sdh.deal_status IN('+@_deal_status+')' ELSE '' END
		+CASE WHEN @_deal_date_from IS NOT NULL THEN ' AND sdh.deal_date>='''+@_deal_date_from +''' AND sdh.deal_date<='''+@_deal_date_to +'''' ELSE '' END  
		+CASE WHEN @_as_of_date IS NOT NULL THEN ' AND sdh.deal_date<='''+convert(varchar(10),@_as_of_date,120) +'''' ELSE '' END 


---print ( @_Sql_Select)    
EXEC ( @_Sql_Select)   	
CREATE INDEX idx_deals_temp ON #temp_deals(source_deal_header_id) 





IF OBJECT_ID(N'tempdb..#temp_block_type_group_table') IS NOT NULL
	DROP TABLE #temp_block_type_group_table

CREATE TABLE #temp_block_type_group_table(block_type_group_id INT, block_type_id INT, block_name VARCHAR(200),hourly_block_id INT)

IF (@_block_type_group_id IS NOT NULL)	
	SET @_Sql_Select = 'INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT block_type_group_id,block_type_id,block_name,hourly_block_id 				
				FROM block_type_group 
				WHERE block_type_group_id=' + CAST(@_block_type_group_id AS VARCHAR(100))
	ELSE 
	SET @_Sql_Select ='INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT NULL block_type_group_id, NULL block_type_id, ''Base load'' block_name, '+@_baseload_block_define_id+' hourly_block_id'

---print ( @_Sql_Select)    
EXEC ( @_Sql_Select) 


create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)



insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
from (
		select distinct isnull(tz.dst_group_value_id,-1) dst_group_value_id,isnull(spcd.block_define_id,nullif(@_baseload_block_define_id,'NULL')) block_define_id,s.term_start,s.term_end 
		from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
		 	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
		 	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
		 		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
		 		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
				LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
					AND ISNULL(tz.curve_id,-1)=ISNULL(s.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
		) a
		outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start  and a.term_end --and term_date>@_as_of_date
		and isnull(h.dst_group_value_id,-1)=a.dst_group_value_id
) hb

create index indxterm_dat on #term_date(block_define_id  ,term_start,term_end)

----print 'CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(2,1))    '

CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(6,2))  

set @_summary_option=isnull(nullif(@_summary_option,'1900'),'m')


if @_summary_option='y' --30 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,48),(981,30,2)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,2),(982,30,2)
end    
else if @_summary_option='x' --15 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,96),(981,15,96),(981,30,96),(981,45,4)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,4),(982,15,4),(982,30,4),(982,45,4)
	
	insert into #minute_break ( granularity ,period , factor )  --30 minute
	values (989,15,2),(989,45,2)
end
   
create index idx_minute_break on #minute_break(granularity, period, factor)

  
--***************************              
--END of source book map table and build index              
--*****************************     

  
-- Collect Required Deals  


SET @_view_nameq='report_hourly_position_deal'
SET @_view_name1='report_hourly_position'



----print '-----------------------@_scrt'
SET @_scrt=''

SET @_scrt= CASE WHEN @_source_deal_header_id IS NOT NULL  THEN ' AND s.source_deal_header_id IN ('+ CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END
	+CASE WHEN @_term_start IS NOT NULL THEN ' AND s.term_start>='''+@_term_start +''' AND s.term_start<='''+@_term_end +'''' ELSE '' END 
	+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND s.commodity_id IN ('+@_commodity_id+')' ELSE '' END
	+CASE WHEN @_curve_id IS NOT NULL THEN ' AND s.curve_id IN ('+@_curve_id+')' ELSE '' END
	+CASE WHEN @_location_id IS NOT NULL THEN ' AND s.location_id IN ('+@_location_id+')' ELSE '' END
	+CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END  
	+CASE WHEN @_physical_financial_flag <>'b' THEN ' AND s.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END

----print @_scrt
----print '--------------------------------------------'

---------------------------Start hourly_position_breakdown=null------------------------------------------------------------
-- formula curve_value

IF OBJECT_ID('tempdb..#formula_curve_value') IS NOT NULL 
DROP TABLE #formula_curve_value

SELECT b.curve_value,CAST(b.term_start AS DATETIME) term_start,b.[hr],b.source_deal_header_id
INTO #formula_curve_value
FROM
(
	SELECT  MAX(spc.curve_value) curve_value
	--, term_break.day_date term_start
	, CAST(spc.maturity_date AS DATE) term_start
	, CASE WHEN spcd.granularity =  982 THEN DATEPART(HOUR, spc.maturity_date) + 1 ELSE a.n END [hr]
	, sdd.source_deal_header_id
	--, spcd.granularity
		--INTO #formula_curve_value
	FROM  source_deal_detail sdd  
	INNER JOIN #temp_deals td ON td.source_deal_header_id = sdd.source_deal_header_id
	--CROSS APPLY  (select * from dbo.FNAGetDayWiseDate(sdd.term_start, sdd.term_end)) term_break
	INNER JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.formula_curve_id
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
		--AND CAST(term_break.day_date AS DATE) = CAST(spc.maturity_date AS DATE)
		AND  CAST(spc.maturity_date AS DATE) BETWEEN sdd.term_start and sdd.term_end
	CROSS APPLY (SELECT N FROM dbo.seq where n < 25) a
	WHERE spc.as_of_date = @_as_of_date
	GROUP BY sdd.source_deal_header_id, CASE WHEN spcd.granularity =  982 THEN DATEPART(HOUR, spc.maturity_date) + 1 ELSE a.n END, CAST(spc.maturity_date AS DATE) --term_break.day_date
) b

IF OBJECT_ID('tempdb..#market_curve_value') IS NOT NULL 
DROP TABLE #market_curve_value

SELECT a.market_curve_value,CAST(a.term_start AS DATETIME) term_start,a.[hr],a.source_deal_header_id
INTO #market_curve_value
FROM
(
	SELECT  MAX(spc.curve_value) market_curve_value
	--, term_break.day_date term_start
	, CAST(spc.maturity_date AS DATE) term_start
	, CASE WHEN spcd.granularity =  982 THEN DATEPART(HOUR, spc.maturity_date) + 1 ELSE a.n END [hr]
	, sdd.source_deal_header_id
	--, spcd.granularity
		--INTO #market_curve_value
	FROM  source_deal_detail sdd  
	INNER JOIN #temp_deals td ON td.source_deal_header_id = sdd.source_deal_header_id
	--CROSS APPLY  (SELECT * FROM dbo.FNAGetDayWiseDate(sdd.term_start, sdd.term_end)) term_break
	INNER JOIN source_price_curve spc ON spc.source_curve_def_id = sdd.curve_id
			--AND CAST(term_break.day_date AS DATE) = CAST(spc.maturity_date AS DATE)
			AND  CAST(spc.maturity_date AS DATE) BETWEEN sdd.term_start and sdd.term_end
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
	CROSS APPLY (SELECT N FROM dbo.seq where n < 25) a
	WHERE spc.as_of_date = @_as_of_date
	GROUP BY sdd.source_deal_header_id, CASE WHEN spcd.granularity =  982 THEN DATEPART(HOUR, spc.maturity_date) + 1 ELSE a.n END,  CAST(spc.maturity_date AS DATE) --term_break.day_date
 ) a
 
 
if isnull(@_include_no_breakdown,'n')='y'
begin

	create table #term_date_no_break( block_define_id int ,term_date date,term_start date,term_end date,
		hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint
		,hr14 tinyint,hr15 tinyint,hr16 tinyint,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,volume_mult int
	)

	set @_rpn='
		select sdh.source_deal_header_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4
		,sdh.deal_date,sdh.counterparty_id,sdh.deal_status deal_status_id,sdd.curve_id,sdd.location_id,sdd.term_start,sdd.term_end,sdd.total_volume
		,spcd.commodity_id,sdd.physical_financial_flag,sdd.deal_volume_uom_id,bk.fas_book_id,sdd.contract_expiration_date expiration_date,
		isnull(spcd.block_define_id,'+@_baseload_block_define_id+') block_define_id

		  into '+ @_position_no_breakdown+'
		from source_deal_header sdh with (nolock) inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
		inner join #temp_deals td on td.source_deal_header_id=sdh.source_deal_header_id
		inner join source_deal_detail sdd with (nolock) on sdh.source_deal_header_id=sdd.source_deal_header_id
		INNER JOIN [deal_status_group] dsg ON dsg.deal_status_group_id = sdh.deal_status 
		' +CASE WHEN isnull(@_source_deal_header_id ,-1) <>-1 THEN ' and sdh.source_deal_header_id IN (' +CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END 
		+'	INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
		AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
	'
	----print @_rpn
	exec(@_rpn)

	set @_rpn='
		insert into #term_date_no_break(block_define_id,term_date,term_start,term_end,
			hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 ,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,volume_mult
		)
		select distinct a.block_define_id,hb.term_date,a.term_start ,a.term_end,
			hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
			,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
			,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult
		from '+@_position_no_breakdown+' a
		LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=a.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(a.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(a.location_id,-1)
				outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and ISNULL(h.dst_group_value_id,-1)=ISNULL(tz.dst_group_value_id ,-1)
				and term_date between a.term_start  and a.term_end --and term_date>'''+convert(varchar(10),@_as_of_date,120) +'''
		) hb
		'
		
	----print @_rpn
	exec(@_rpn)

	create index indxterm_dat_no_break on #term_date_no_break(block_define_id,term_start,term_end)
	
	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
	
	SET @_vol_multiplier='*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))'+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end
	
	SET @_rpn='Union all
	select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,'+case when @_summary_option in ('x','y')  then ' hrs.period ' else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,cast(isnull(hb.hr1,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END '+ @_vol_multiplier +'  AS Hr1
		,cast(isnull(hb.hr2,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr2
		,cast(isnull(hb.hr3,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr3
		,cast(isnull(hb.hr4,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr4
		,cast(isnull(hb.hr5,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr5
		,cast(isnull(hb.hr6,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr6
		,cast(isnull(hb.hr7,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr7
		,cast(isnull(hb.hr8,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr8
		,cast(isnull(hb.hr9,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr9
		,cast(isnull(hb.hr10,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr10
		,cast(isnull(hb.hr11,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr11
		,cast(isnull(hb.hr12,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr12
		,cast(isnull(hb.hr13,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr13'
	
	SET @_rpn1= ',cast(isnull(hb.hr14,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr14
		,cast(isnull(hb.hr15,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr15
		,cast(isnull(hb.hr16,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr16
		,cast(isnull(hb.hr17,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr17
		,cast(isnull(hb.hr18,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr18
		,cast(isnull(hb.hr19,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr19
		,cast(isnull(hb.hr20,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr20
		,cast(isnull(hb.hr21,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr21
		,cast(isnull(hb.hr22,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr22
		,cast(isnull(hb.hr23,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr23
		,cast(isnull(hb.hr24,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr24
		,'+@_dst_column+ @_vol_multiplier+' AS Hr25 ' 
	
	SET @_rpn2=
		',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date ,''y'' AS is_fixedvolume ,deal_status_id 
		 from '+@_position_no_breakdown + ' s inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id'
		+' left join #term_date_no_break hb on hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.block_define_id=s.block_define_id --and hb.term_date>''' + @_as_of_date +''''
		+case when @_summary_option in ('x','y')  then 
			' left join #minute_break hrs on hrs.granularity=982 '
		else '' end+'
		outer apply ( select sum(volume_mult) term_hrs from #term_date_no_break h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>''' + @_as_of_date +''') term_hrs
	    where 1=1' +@_scrt



end

	---------------------------end hourly_position_breakdown=null------------------------------------------------------------
	
if @_physical_financial_flag<>'p' 
BEGIN 
	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
	--SET @_remain_month ='*(CASE WHEN YEAR(hb.term_date)=YEAR(DATEADD(m,1,'''+@_as_of_date+''')) AND MONTH(hb.term_date)=MONTH(DATEADD(m,1,'''+@_as_of_date+''')) THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'            	
	SET @_remain_month ='*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end    
		
	--SET @_dst_column='CASE WHEN (dst.insert_delete)=''i'' THEN isnull(CASE dst.hour WHEN 1 THEN hb.hr1 WHEN 2 THEN hb.hr2 WHEN 3 THEN hb.hr3 WHEN 4 THEN hb.hr4 WHEN 5 THEN hb.hr5 WHEN 6 THEN hb.hr6 WHEN 7 THEN hb.hr7 WHEN 8 THEN hb.hr8 WHEN 9 THEN hb.hr9 WHEN 10 THEN hb.hr10 WHEN 11 THEN hb.hr11 WHEN 12 THEN hb.hr12 WHEN 13 THEN hb.hr13 WHEN 14 THEN hb.hr14 WHEN 15 THEN hb.hr15 WHEN 16 THEN hb.hr16 WHEN 17 THEN hb.hr17 WHEN 18 THEN hb.hr18 WHEN 19 THEN hb.hr19 WHEN 20 THEN hb.hr20 WHEN 21 THEN hb.hr21 WHEN 22 THEN hb.hr22 WHEN 23 THEN hb.hr23 WHEN 24 THEN hb.hr24 END,0) END'              	
	SET @_vol_multiplier='/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))'
		

	SET @_rhpb='select s.curve_id,'+ CASE WHEN @_view_name1='vwHourly_position_AllFilter' THEN '-1' ELSE 'ISNULL(s.location_id,-1)' END +' location_id,hb.term_date term_start,'+case when @_summary_option in ('x','y')  then ' hrs.period '	else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr1
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr2
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr3
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr4
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr5
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr6
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr7
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr8
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr9
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr10
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr11
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr12
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr13'
		
	SET @_rhpb1= ',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr14
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr15
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr16
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr17
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr18
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr19
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr20
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr21
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr22
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr23
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr24
		,(cast(cast(s.calc_volume as numeric(22,10))* '+@_dst_column+' as numeric(22,10))) '+ @_vol_multiplier +@_remain_month+' AS Hr25 ' 
		
	SET @_rhpb2=
			',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume ,deal_status_id 
			from '+@_view_name1+'_breakdown s '+CASE WHEN @_view_nameq='vwHourly_position_AllFilter' THEN ' WITH(NOEXPAND) ' ELSE ' (nolock) ' END +' 
			 inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
			INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN ' and s.source_deal_header_id IN (' +CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END 
			+'	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 ' 
		+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		'	INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id ' ELSE '' END 
		+' LEFT JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
		LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(s.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
		LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
		outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END and hbt.dst_group_value_id=tz.dst_group_value_id) term_hrs
		outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt 
		inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date 
		where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END and  ISNULL(hbt.dst_group_value_id,-1)=ISNULL(tz.dst_group_value_id,-1)) term_hrs_exp
		left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,'+@_baseload_block_define_id+') and hb.term_start = s.term_start
		and hb.term_end=s.term_end  --and hb.term_date>''' + @_as_of_date +'''
		outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
			outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@_as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  '
		+case when @_summary_option in ('x','y')  then 
			' left join #minute_break hrs on hrs.granularity=982 '
		else '' end+'
		    where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@_as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		    ' +CASE WHEN @_tenor_option <> 'a' THEN ' and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@_as_of_date+'''' ELSE '' END + 
			@_scrt
			
	----print @_Sql_Select
	--EXEC(@_Sql_Select)			
END



	--select @_group_by, @_summary_option,@_format_option		
	
IF  @_summary_option IN ('d' ,'m','q','a')																																																														
BEGIN
	
	SET @_volume_clm=''
	SET @_volume_clm=CASE WHEN @_summary_option = 'm' THEN '('ELSE 'SUM(' END
		
	IF @_volume_clm IN ('(','SUM(')
	BEGIN
		SET @_volume_clm=@_volume_clm + 'ROUND('+ CASE WHEN  @_summary_option = 'm' THEN 'SUM(' ELSE '' END +
				'CAST((cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr7 else hb.hr1 end *' else '' end +'vw.hr1 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr8 else hb.hr2 end *' else '' end +'vw.hr2 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr3 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr10 else hb.hr4 end *' else '' end +'vw.hr4 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr11 else hb.hr5 end *' else '' end +'vw.hr5 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr12 else hb.hr6 end *' else '' end +'vw.hr6 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr13 else hb.hr7 end *' else '' end +'vw.hr7 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr14 else hb.hr8 end *' else '' end +'vw.hr8 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr15 else hb.hr9 end *' else '' end +'vw.hr9 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr16 else hb.hr10 end *' else '' end +'vw.hr10 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr17 else hb.hr11 end *' else '' end +'vw.hr11 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr18 else hb.hr12 end *' else '' end +'vw.hr12 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr19 else hb.hr13 end *' else '' end +'vw.hr13 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr20 else hb.hr14 end *' else '' end +'vw.hr14 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr21 else hb.hr15 end *' else '' end +'vw.hr15 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr22 else hb.hr16 end *' else '' end +'vw.hr16 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr23 else hb.hr17 end *' else '' end +'vw.hr17 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr24 else hb.hr18 end *' else '' end +'vw.hr18 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr1 else hb.hr19 end *' else '' end +'vw.hr19 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr2 else hb.hr20 end *' else '' end +'vw.hr20 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr3 else hb.hr21 end *' else '' end +'vw.hr21 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr4 else hb.hr22 end *' else '' end +'vw.hr22 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr5 else hb.hr23 end *' else '' end +'vw.hr23 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				+(cast('+case when @_group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr6 else hb.hr24 end *' else '' end +'vw.hr24 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
				AS NUMERIC(38, 10))  ' + CASE WHEN @_summary_option = 'm' THEN ')' ELSE '' END +', ' + @_round_value + ' )) Volume ,' 
			+ CASE @_summary_option WHEN 'd' THEN '''Daily'' AS Frequency,'
								WHEN 'm' THEN '''Monthly'' AS Frequency,'
								WHEN 'q' THEN '''Quarterly'' AS Frequency,'
								WHEN 'a' THEN '''Annually'' AS Frequency,'
								ELSE ''						 
			END 
	END
END--@_summary_option IN ('d' ,'m','q','a')
ELSE 
	SET @_volume_clm=
		CASE WHEN @_summary_option='m' THEN '''Monthly'' AS Frequency,' WHEN @_summary_option='d' THEN '''Daily'' AS Frequency,' WHEN @_summary_option='a' THEN '''Annually'' AS Frequency,' WHEN @_summary_option='q' THEN '''Quarterly'' AS Frequency,' ELSE '' END +
			'ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr7 else hb.hr1 end *' else '' end +'vw.hr1 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '7' ELSE '1' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr8 else hb.hr2 end *' else '' end +'vw.hr2 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '8' ELSE '2' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr3 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '9' ELSE '3' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr10 else hb.hr4 end *' else '' end +'vw.hr4 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '10' ELSE '4' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr11 else hb.hr5 end *' else '' end +'vw.hr5 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '11' ELSE '5' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr12 else hb.hr6 end *' else '' end +'vw.hr6 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '12' ELSE '6' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr13 else hb.hr7 end *' else '' end +'vw.hr7 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '13' ELSE '7' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr14 else hb.hr8 end *' else '' end +'vw.hr8 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '14' ELSE '8' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr15 else hb.hr9 end *' else '' end +'vw.hr9 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '15' ELSE '9' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr16 else hb.hr10 end *' else '' end +'vw.hr10 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '16' ELSE '10' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr17 else hb.hr11 end *' else '' end +'vw.hr11 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '17' ELSE '11' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr18 else hb.hr12 end *' else '' end +'vw.hr12 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '18' ELSE '12' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr19 else hb.hr13 end *' else '' end +'vw.hr13 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '19' ELSE '13' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr20 else hb.hr14 end *' else '' end +'vw.hr14 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '20' ELSE '14' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr21 else hb.hr15 end *' else '' end +'vw.hr15 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '21' ELSE '15' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr22 else hb.hr16 end *' else '' end +'vw.hr16 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '22' ELSE '16' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr23 else hb.hr17 end *' else '' end +'vw.hr17 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '23' ELSE '17' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr24 else hb.hr18 end *' else '' end +'vw.hr18 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '24' ELSE '18' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr1 else hb.hr19 end *' else '' end +'vw.hr19 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '1' ELSE '19' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr2 else hb.hr20 end *' else '' end +'vw.hr20 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '2' ELSE '20' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr3 else hb.hr21 end *' else '' end +'vw.hr21 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '3' ELSE '21' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr4 else hb.hr22 end *' else '' end +'vw.hr22 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '4' ELSE '22' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr5 else hb.hr23 end *' else '' end +'vw.hr23 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '5' ELSE '23' END  +',
			ROUND((cast(SUM(cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr6 else hb.hr24 end *' else '' end +'vw.hr24 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '6' ELSE '24' END  +',
		'+CASE WHEN @_format_option ='r' THEN +'ROUND((cast(SUM(cast('+case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr25 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr25,' ELSE '' END

		
SET @_sqry='select s.curve_id,s.location_id,s.term_start,'+
		+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) END else  COALESCE(hrs.period,s.period) end'
				when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
				else '0'
		end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
		+case  @_summary_option when 'y' then  
				' s.hr1/COALESCE(hrs.factor,1) hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1) hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				, s.hr5/COALESCE(hrs.factor,1) hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1) hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1) hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1) hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1) hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1) hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1) hr21, s.hr22/COALESCE(hrs.factor,1) hr22
				,s.hr23/COALESCE(hrs.factor,1) hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1) hr25'				
			when 'x' then  
				' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1) hr2
				,s.hr3 /COALESCE(hrs.factor,m30.factor,1) hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1) hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1) hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1) hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1) hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1) hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1) hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1) hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1) hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1) hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1) hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1) hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1) hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1) hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1) hr21, s.hr22 /COALESCE(hrs.factor,m30.factor,1) hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1) hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,m30.factor,1) hr25'				
			else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
		end
	+',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
		,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id 
	INTO '+ @_position_deal +'  
	from '+@_view_nameq+' s  (nolock) inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id 
	INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
							when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
							else ''
	end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 

		
SET @_sqry1='
	union all
	select s.curve_id,s.location_id,s.term_start,'
		+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
				when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
				else '0'
		end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
		+case  @_summary_option	when 'y' then  
				' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25'				
			when 'x' then  
				' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
					
			else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
		end
	+',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
	,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id
	from '+@_view_name1+'_profile s  (nolock) inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id'  
	+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
							when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
							else ''
	end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 
				
			
	SET @_sqry2='
	union all
	select s.curve_id,s.location_id,s.term_start,'
		+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
				when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
				else '0'
		end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
		+case  @_summary_option	when 'y' then  
				' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25'				
			when 'x' then  
				' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
			else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
		end
	+',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
			,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id
	from '+replace(@_view_nameq,'_deal','')+'_financial s  (nolock) inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
							when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
											left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
							else ''
	end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 			
			

IF @_physical_financial_flag <> 'x'
	SET @_rhpb	='	union all ' + @_rhpb	
ELSE
BEGIN
	SET @_rhpb	=''
	SET @_rhpb1	=''
	SET @_rhpb2	=''
	SET @_rhpb3	=''
END	
				
	
set @_rpn=isnull(@_rpn,'')
set @_rpn1= isnull(@_rpn1,'')
set @_rpn2=isnull(@_rpn2,'')

--print @_sqry
--print @_sqry1
--print @_sqry2


--print '-----------------'
--print '-----------------'
--print @_rhpb
--print @_rhpb1
--print @_rhpb2
--print '-----------------'
--print @_rpn
--print @_rpn1
--print @_rpn2


		
exec(
	@_sqry +@_sqry1+@_sqry2+ @_rhpb+ @_rhpb1+ @_rhpb2
	+ @_rpn+@_rpn1+@_rpn2
)
		
	
exec('CREATE INDEX indx_tmp_subqry1'+@_temp_process_id+' ON '+@_position_deal +'(curve_id);
	CREATE INDEX indx_tmp_subqry2'+@_temp_process_id+' ON '+@_position_deal +'(location_id);
	CREATE INDEX indx_tmp_subqry3'+@_temp_process_id+' ON '+@_position_deal +'(counterparty_id)'
)
	


SET @_Sql_Select=  
	' SELECT  isnull(sdd.source_deal_detail_id,sdd_fin.source_deal_detail_id ) source_deal_detail_id,vw.physical_financial_flag,su.source_uom_id
		,isnull(spcd1.source_curve_def_id,spcd.source_curve_def_id) source_curve_def_id,vw.location_id,vw.counterparty_id,vw.fas_book_id,'
		+CASE WHEN  @_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' ELSE CASE WHEN @_summary_option='m' THEN 'convert(varchar(7),vw.term_start,120)' WHEN @_summary_option='a' THEN 'year(vw.term_start)' WHEN @_summary_option='q' THEN 'dbo.FNATermGrouping(vw.term_start,''q'')'  ELSE 'vw.term_start' END END+' [Term], '
		+CASE WHEN  @_summary_option IN ('x','y')  THEN 'vw.period' ELSE '0' END+' [Period], '
			+ @_volume_clm+' max(su.uom_name) [UOM],MAX(vw.commodity_id) commodity_id,MAX(vw.is_fixedvolume) is_fixedvolume
		INTO '+@_hour_pivot_table 
	+' FROM  '

SET @_rhpb3=
		'  vw '
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
			'INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = vw.deal_status_id' 
		ELSE '' END +'
			INNER JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=vw.curve_id 
			left join dbo.source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id and sdd.curve_id=vw.curve_id 
				and vw.term_start between sdd.term_start and sdd.term_end and vw.is_fixedvolume=''n''
			outer apply
			( select top(1) * from dbo.source_deal_detail where vw.is_fixedvolume=''y'' and source_deal_header_id=vw.source_deal_header_id) sdd_fin 
			LEFT JOIN  source_price_curve_def spcd1 (nolock) ON  spcd1.source_curve_def_id='+CASE WHEN @_proxy_curve_view = 'y' THEN  'spcd.proxy_curve_id' ELSE 'spcd.source_curve_def_id' END
		+' LEFT JOIN source_minor_location sml (nolock) ON sml.source_minor_location_id=vw.location_id
			left join static_data_value sdv1 (nolock) on sdv1.value_id=sml.grid_value_id
			left join static_data_value sdv (nolock)  on sdv.value_id=sml.country
			left join static_data_value sdv2 (nolock) on sdv2.value_id=sml.region
			left join static_data_value sdv_prov (nolock) on sdv_prov.value_id=sml.province
			left join source_major_location mjr (nolock) on  sml.source_major_location_ID=mjr.source_major_location_ID
			left join source_counterparty scp (nolock) on vw.counterparty_id = scp.source_counterparty_id	
			LEFT JOIN source_uom su (nolock) on su.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
	WHERE 1=1 ' +
	CASE WHEN @_term_start IS NOT NULL THEN ' AND vw.term_start>='''+CAST(@_term_start AS VARCHAR)+''' AND vw.term_start<='''+CAST(@_term_END AS VARCHAR)+'''' ELSE '' END  
	+CASE WHEN @_parent_counterparty IS NOT NULL THEN ' AND  scp.parent_counterparty_id = ' + CAST(@_parent_counterparty AS VARCHAR) ELSE  '' END
	+CASE WHEN @_counterparty IS NOT NULL THEN ' AND vw.counterparty_id IN (' + @_counterparty + ')' ELSE '' END
	+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND vw.commodity_id IN('+@_commodity_id+')' ELSE '' END
	+CASE WHEN @_curve_id IS NOT NULL THEN ' AND vw.curve_id IN('+@_curve_id+')' ELSE '' END
	+CASE WHEN @_location_id IS NOT NULL THEN ' AND vw.location_id IN('+@_location_id+')' ELSE '' END
	+CASE WHEN @_tenor_option <> 'a' THEN ' AND vw.expiration_date>'''+@_as_of_date+''' AND vw.term_start>'''+@_as_of_date+'''' ELSE '' END  
	+CASE WHEN @_physical_financial_flag <>'b' THEN ' AND vw.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END
	+CASE WHEN @_country IS NOT NULL THEN ' AND sdv.value_id='+ CAST(@_country AS VARCHAR) ELSE '' END
	+CASE WHEN @_region IS NOT NULL THEN ' AND sdv2.value_id='+ CAST(@_region AS VARCHAR) ELSE '' END
	+CASE WHEN @_location_group_id IS NOT NULL THEN ' AND mjr.source_major_location_id='+ @_location_group_id ELSE '' END
	+CASE WHEN @_grid IS NOT NULL THEN ' AND sdv1.value_id='+ @_grid ELSE '' END
	+CASE WHEN @_province IS NOT NULL THEN ' AND sdv_prov.value_id='+ @_province ELSE '' END
 	+CASE WHEN @_deal_status IS NOT NULL THEN ' AND deal_status_id IN('+@_deal_status+')' ELSE '' END
	+CASE WHEN @_buy_sell_flag is not null THEN ' AND  isnull(sdd.buy_sell_flag,sdd_fin.buy_sell_flag)='''+@_buy_sell_flag+'''' ELSE '' END
	+' GROUP BY isnull(sdd.source_deal_detail_id,sdd_fin.source_deal_detail_id ),isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.location_id,'
			+CASE WHEN  @_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' ELSE CASE WHEN @_summary_option='m' THEN 'convert(varchar(7),vw.term_start,120)' WHEN @_summary_option='a' THEN 'year(vw.term_start)' WHEN @_summary_option='q' THEN 'dbo.FNATermGrouping(vw.term_start,''q'')'  ELSE 'vw.term_start' END END
			+CASE WHEN  @_summary_option IN ('x','y')  THEN ',vw.period' ELSE '' END+',su.source_uom_id,vw.physical_financial_flag,vw.counterparty_id,vw.fas_book_id'  --,vw.commodity_id
					



--print (@_Sql_Select)
--print '-----------------------------'
--print(@_position_deal)
--print '-----------------------------'

--print @_rhpb3
--print '-----------------------------'
				
exec( @_Sql_Select+@_position_deal+@_rhpb3)
--return

----print 'iiiiiiiiiiiiiiiiiiii'
--	--return

	
		
SET @_rhpb='SELECT s.source_deal_detail_id,s.source_curve_def_id,s.commodity_id,s.[Term],s.Period,s.is_fixedvolume,s.physical_financial_flag,s.source_uom_id,[UOM],counterparty_id,s.location_id,s.fas_book_id,'

if  @_summary_option IN ('h','x','y') 
begin
	set @_volume_clm='
		CAST(hb1.hr1*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr19 ELSE s.hr1 END - CASE WHEN hb.add_dst_hour=1 THEN isnull(s.hr25,0) ELSE 0 END ) AS NUMERIC(38,20)) [1],
		CAST(hb1.hr2*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr20 ELSE s.hr2 END - CASE WHEN hb.add_dst_hour=2 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [2],
		CAST(hb1.hr3*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr21 ELSE s.hr3 END - CASE WHEN hb.add_dst_hour=3 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [3],
		CAST(hb1.hr4*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr22 ELSE s.hr4 END - CASE WHEN hb.add_dst_hour=4 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [4],
		CAST(hb1.hr5*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr23 ELSE s.hr5 END - CASE WHEN hb.add_dst_hour=5 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [5],
		CAST(hb1.hr6*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr24 ELSE s.hr6 END - CASE WHEN hb.add_dst_hour=6 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [6],
		CAST(hb1.hr7*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr1 ELSE s.hr7 END - CASE WHEN hb.add_dst_hour=7 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [7],
		CAST(hb1.hr8*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr2 ELSE s.hr8 END - CASE WHEN hb.add_dst_hour=8 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [8],
		CAST(hb1.hr9*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr3 ELSE s.hr9 END - CASE WHEN hb.add_dst_hour=9 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [9],
		CAST(hb1.hr10*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr4 ELSE  s.hr10 END - CASE WHEN hb.add_dst_hour=10 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [10],
		CAST(hb1.hr11*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr5 ELSE  s.hr11 END - CASE WHEN hb.add_dst_hour=11 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [11],
		CAST(hb1.hr12*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr6 ELSE  s.hr12 END - CASE WHEN hb.add_dst_hour=12 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [12],
		CAST(hb1.hr13*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr7 ELSE  s.hr13 END - CASE WHEN hb.add_dst_hour=13 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [13],
		CAST(hb1.hr14*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr8 ELSE  s.hr14 END - CASE WHEN hb.add_dst_hour=14 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [14],
		CAST(hb1.hr15*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr9 ELSE  s.hr15 END - CASE WHEN hb.add_dst_hour=15 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [15],
		CAST(hb1.hr16*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr10 ELSE s.hr16 END - CASE WHEN hb.add_dst_hour=16 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [16],
		CAST(hb1.hr17*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr11 ELSE s.hr17 END - CASE WHEN hb.add_dst_hour=17 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [17],
		CAST(hb1.hr18*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr12 ELSE s.hr18 END - CASE WHEN hb.add_dst_hour=18 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [18],
		CAST(hb1.hr19*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr13 ELSE s.hr19 END - CASE WHEN hb.add_dst_hour=19 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [19],
		CAST(hb1.hr20*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr14 ELSE s.hr20 END - CASE WHEN hb.add_dst_hour=20 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [20],
		CAST(hb1.hr21*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr15 ELSE s.hr21 END - CASE WHEN hb.add_dst_hour=21 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [21],
		CAST(hb1.hr22*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr16 ELSE s.hr22 END - CASE WHEN hb.add_dst_hour=22 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [22],
		CAST(hb1.hr23*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr17 ELSE s.hr23 END - CASE WHEN hb.add_dst_hour=23 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [23],
		CAST(hb1.hr24*(CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr18 ELSE s.hr24 END - CASE WHEN hb.add_dst_hour=24 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [24],
		CAST(hb1.hr3*(s.hr25) AS NUMERIC(38,20)) [25],cast(hb1.hr3*(s.hr25) AS NUMERIC(38,20)) dst_hr,(hb.add_dst_hour) add_dst_hour
		,ISNULL(grp.block_type_id, spcd.source_curve_def_id)  block_type_id,   ISNULL(grp.block_name, spcd.curve_name) block_name
		, sdv_block_group.code [user_defined_block] ,sdv_block_group.value_id [user_defined_block_id],grp.block_type_group_id '




	SET @_rhpb_0= ' 
		select *,'
		+CASE WHEN  @_summary_option IN ('h','x','y')  THEN 'CASE WHEN commodity_id=-1 AND is_fixedvolume =''n'' AND  ([hours]<7 OR [hours]=25) THEN dateadd(DAY,1,[term]) ELSE [term] END' else  '[term]' end +' [term_date] 
		into #unpvt 
		from (
			SELECT * FROM #tmp_pos_detail_power
			union all 
			SELECT * FROM #tmp_pos_detail_gas
		) p
		UNPIVOT
			(Volume for Hours IN
				([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
			) AS unpvt
		WHERE NOT ([hours]=abs(isnull(add_dst_hour,0)) AND add_dst_hour<0) '
		+CASE WHEN @_block_type_group_id is not null  THEN ' and Volume<>0' else '' end
end
else 
begin
	set @_volume_clm='Volume 
		,null block_type_id,null block_name, null [user_defined_block] ,null [user_defined_block_id],null block_type_group_id
		'

		set @_rhpb_0=''
end
--exec (@_rhpb_0)
set @_commodity_str=' INTO #tmp_pos_detail_power FROM '+@_hour_pivot_table+' s 
		inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id  AND not (s.commodity_id=-1 AND s.is_fixedvolume =''n'') 
	'
	+case when  @_summary_option IN ('h','x','y') then
	'	inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = s.source_deal_detail_id
		inner JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
		inner JOIN hour_block_term hb ON hb.term_date =s.[term]
			and hb.block_define_id = COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+') and  hb.block_type=12000
			and  isnull(hb.dst_group_value_id,-1)=isnull(tz.dst_group_value_id,-1)
		CROSS JOIN #temp_block_type_group_table grp
		LEFT JOIN  hour_block_term hb1 WITH (NOLOCK)  ON hb1.block_define_id=COALESCE(grp.hourly_block_id,'+@_baseload_block_define_id+') AND hb1.block_type=COALESCE(grp.block_type_id,12000) 
			and s.term=hb1.term_date
			and  isnull(hb1.dst_group_value_id,-1)=isnull(tz.dst_group_value_id,-1)
		LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK) ON sdv_block_group.value_id = grp.block_type_group_id
	'
	else '' end


set @_commodity_str1=' INTO #tmp_pos_detail_gas FROM '+@_hour_pivot_table+' s  
	inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id and s.commodity_id=-1 AND s.is_fixedvolume =''n''
	'
+case when  @_summary_option IN ('h','x','y') then
	'	inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = s.source_deal_detail_id
		inner JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
		inner JOIN hour_block_term hb ON  hb.term_date-1=s.[term] 
		AND hb.block_define_id =COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+') 
		and  hb.block_type=12000 
		and  isnull(hb.dst_group_value_id,-1)=isnull(tz.dst_group_value_id,-1)
		CROSS JOIN #temp_block_type_group_table grp
		LEFT JOIN  hour_block_term hb1 WITH (NOLOCK)  ON hb1.block_define_id=COALESCE(grp.hourly_block_id,'+@_baseload_block_define_id+') AND hb1.block_type=COALESCE(grp.block_type_id,12000) 
		and s.term=hb1.term_date
		and  isnull(hb1.dst_group_value_id,-1)=isnull(tz.dst_group_value_id,-1)
		LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK) ON sdv_block_group.value_id = grp.block_type_group_id
	'
else '' end

SET @_rhpb1= '
SELECT 
	'''+isnull(@_as_of_date,'')+''' as_of_date,
	sub.entity_id sub_id,
	stra.entity_id stra_id,
	book.entity_id book_id,
	sub.entity_name sub,
	stra.entity_name strategy,
	book.entity_name book,
	sdh.source_deal_header_id,
	sdh.deal_id deal_id,
	CASE WHEN vw.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END physical_financial_flag,
	sdh.deal_date deal_date,
	sml.Location_Name location,
	spcd.source_curve_def_id [index_id],
	spcd.curve_name [index],
	spcd_proxy.curve_name proxy_index,
	spcd_proxy.source_curve_def_id proxy_index_id,
	sdv2.code region,
	sdv2.value_id region_id,
	sdv.code country,
	sdv.value_id country_id,
	sdv1.code grid,
	sdv1.value_id grid_id,
	sdv_prov.code Province,
	sdv_prov.value_id Province_id,
	mjr.location_name location_group,
	com.commodity_name commodity,
	sc.counterparty_name counterparty_name,
	sc.counterparty_name parent_counterparty,
	sb1.source_book_name book_identifier1,
	sb2.source_book_name book_identifier2,
	sb3.source_book_name book_identifier3,
	sb4.source_book_name book_identifier4,
	sb1.source_book_id book_identifier1_id,
	sb2.source_book_id book_identifier2_id,
	sb3.source_book_id book_identifier3_id,
	sb4.source_book_id book_identifier4_id,
	ssbm.logical_name AS sub_book,
	spcd_monthly_index.curve_name + CASE WHEN sssd.source_system_id = 2 THEN '''' ELSE ''.'' + sssd.source_system_name END AS [proxy_curve2],
	su_uom_proxy2.uom_name [proxy2_position_uom],
	spcd_proxy_curve3.curve_name + CASE WHEN sssd2.source_system_id = 2 THEN '''' ELSE ''.'' + sssd2.source_system_name END AS [proxy_curve3],
	su_uom_proxy3.uom_name [proxy3_position_uom], 
	sdv_block.code [block_definition],
	sdv_block.value_id [block_definition_id],
	CASE WHEN sdd.deal_volume_frequency = ''h'' THEN ''Hourly''
		WHEN sdd.deal_volume_frequency = ''d'' THEN ''Daily''
		WHEN sdd.deal_volume_frequency = ''m'' THEN ''Monthly''
		WHEN sdd.deal_volume_frequency = ''t'' THEN ''Term''
		WHEN sdd.deal_volume_frequency = ''a'' THEN  ''Annually''     
		WHEN sdd.deal_volume_frequency = ''x'' THEN ''15 Minutes''      
		WHEN sdd.deal_volume_frequency = ''y'' THEN  ''30 Minutes''   
	END  [deal_volume_frequency]   ,
	spcd_proxy_curve_def.curve_name [proxy_curve],
	spcd_proxy_curve_def.source_curve_def_id [proxy_curve_id],
	su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
	sc.source_counterparty_id counterparty_id,
	sml.source_minor_location_id location_id,  
	su_uom_proxy_curve.uom_name proxy_index_position_uom,
	ssbm.book_deal_type_map_id [sub_book_id] ,
	spcd.proxy_curve_id3,
	sdd.contract_expiration_date expiration_date,
	spcd.commodity_id,
	vw.block_name,
	vw.block_type_id,
    vw.[user_defined_block] ,
    vw.[user_defined_block_id] 
	,vw.block_type_group_id
              --       ,sdd.buy_sell_flag
	,case when sdd.buy_sell_flag=''b'' then ''Buy'' else ''Sell'' end buy_sell_flag
	,tdr.trader_name [Trader]
	,tdr.source_trader_id [Trader_id]
	,cg.contract_name [Contract]
	,cg.contract_id [Contract_id]
	,sdv_confirm.code [Confirm Status]
	,sdv_confirm.value_id confirm_status_id
	,sdv_deal_staus.code [Deal Status]
	,sdv_deal_staus.value_id deal_status_id
	,sdv_profile.code Profile
	,sdv_profile.value_id profile_id
	,sdd.deal_volume [Deal Volume]
	,su.uom_name [Volume UOM]
	,sdd.schedule_volume [Scheduled Volume]
	,sdd.actual_volume [Actual Volume]
	,left('+CASE WHEN  @_summary_option IN ('m','q','a')  THEN 'vw.term_date' ELSE 'convert(varchar(10),vw.term_date,120)' END+',4)  term_year
	,vw.term_date term_end
	,'+CASE WHEN @_summary_option='a' THEN 'null' else 
	'left('+CASE WHEN  @_summary_option IN ('m','q','a')  THEN 'vw.term_date' ELSE 'convert(varchar(10),vw.term_date,120)' END+',7) ' end +' term_year_month
	,vw.term_date term_start,	
     vw.volume Position,
	su_uom.uom_name [uom],
	su_pos_uom.uom_name [postion_uom],
	sc.int_ext_flag,
	sdv_entity.value_id entity_type_id,
	sdv_entity.code entity_type,
	bkr.counterparty_name Broker,
	bkr.source_counterparty_id broker_id,
	sdt.source_deal_type_id	deal_type_id,
	sdst.source_deal_type_id deal_sub_type_id,
	sdt.source_deal_type_name	[Deal Type],
	sdst.source_deal_type_name [Deal Sub Type],
mjr.source_major_location_id location_group_id,
'
+isnull(@_period_from,'null') +' period_from,'
+isnull(@_period_to,'null')+' period_to,
	'
	+case when  @_summary_option IN ('h','x','y') then
	'vw.Period,CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END [Hour],
		CASE WHEN vw.[Hours] = 25 THEN 0 ELSE 	
			CASE WHEN CAST(convert(varchar(10),vw.[term_date],120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END -1 AS VARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(varchar(10),mv2.[date],120)+'' ''+CAST(mv2.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) 
				AND CAST(convert(varchar(10),mv3.[date],120)+'' ''+CAST(mv3.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME)
					THEN 1 ELSE 0 END 
		END AS DST'
	else 'null Period,null [Hour],null DST' end +'
	,'''+isnull(@_deal_date_from,'')+''' [Deal Date From]
	,'''+isnull(@_deal_date_to,'')+''' [Deal Date To]
	,'''+isnull(@_tenor_option,'')+''' tenor_option
	,'''+isnull(@_summary_option,'')+''' summary_option
	, ' + CASE WHEN @_summary_option IN ('h', 'd', 'm') THEN 'ISNULL(sddh.price, sdd.fixed_price)' ELSE 'sdd.fixed_price' END + ' fixed_price
	, sdd.price_adder price_adder
	, spcd_formula_curve.curve_name formula_curve_name
	, curr.currency_name price_currency
, sdh.ext_deal_id
, ' + case when  @_summary_option IN ('h','x','y') then 'fcv.curve_value' ELSE 'NULL' END + ' curve_value
, ' + case when  @_summary_option IN ('h','x','y') then 'mcv.market_curve_value' ELSE 'NULL' END + ' market_curve_value
, hg.exp_date [payment_date]
, ' + CASE 
	WHEN  'fixed_price' IS NOT NULL  
		THEN ' (-1)*ISNULL(ISNULL(sddh.price, sdd.fixed_price) *  vw.volume,0) '
	ELSE  '(-1)*isnull((fcv.curve_value + sdd.price_adder)* vw.volume,0)' 
END + ' AS [contract_values]
, 0 [adjusted_payment_date_amt]
,'+isnull(@_holiday_calendar_id,'')+' holiday_calendar_id
'

set @_rhpb2='
	
	FROM '
		+case when  @_summary_option IN ('h','x','y') then	'#unpvt'
		else 
			'
			(
				SELECT *,[term] term_date FROM #tmp_pos_detail_power
				union all 
				SELECT *,[term] term_date FROM #tmp_pos_detail_gas
			)'
		end +' vw 
	LEFT JOIN source_minor_location sml WITH (NOLOCK) ON sml.source_minor_location_id = vw.location_id
	INNER JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = vw.source_curve_def_id  
	LEFT JOIN  source_price_curve_def spcd_proxy WITH (NOLOCK) ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
	LEFT JOIN  source_price_curve_def spcd_proxy_curve3 WITH (NOLOCK) ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
	LEFT JOIN  source_price_curve_def spcd_monthly_index WITH (NOLOCK) ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
	LEFT JOIN  source_price_curve_def spcd_proxy_curve_def WITH (NOLOCK) ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
	LEFT JOIN source_system_description sssd WITH (NOLOCK) ON sssd.source_system_id = spcd_monthly_index.source_system_id
	LEFT JOIN source_system_description sssd2 WITH (NOLOCK) ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
	LEFT JOIN static_data_value sdv1 WITH (NOLOCK) ON sdv1.value_id=sml.grid_value_id
	LEFT JOIN static_data_value sdv WITH (NOLOCK) ON sdv.value_id=sml.country
	LEFT JOIN static_data_value sdv2 WITH (NOLOCK) ON sdv2.value_id=sml.region
	LEFT JOIN static_data_value sdv_prov WITH (NOLOCK) ON sdv_prov.value_id=sml.Province
	LEFT JOIN source_major_location mjr WITH (NOLOCK) ON sml.source_major_location_ID=mjr.source_major_location_ID
	LEFT JOIN source_uom AS su_pos_uom WITH (NOLOCK) ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
	LEFT JOIN source_uom su_uom  WITH (NOLOCK)ON su_uom.source_uom_id= spcd.uom_id
	LEFT JOIN source_uom su_uom_proxy3 WITH (NOLOCK) ON su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
	LEFT JOIN source_uom su_uom_proxy2 WITH (NOLOCK) ON su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
	LEFT JOIN source_uom su_uom_proxy_curve_def WITH (NOLOCK) ON su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
	LEFT JOIN source_uom su_uom_proxy_curve WITH (NOLOCK) ON su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
	LEFT JOIN source_counterparty sc WITH (NOLOCK) ON sc.source_counterparty_id = vw.counterparty_id 
	LEFT JOIN source_counterparty psc  WITH (NOLOCK) ON psc.source_counterparty_id=sc.parent_counterparty_id
	LEFT JOIN source_commodity com  WITH (NOLOCK) ON com.source_commodity_id=vw.commodity_id 
	LEFT JOIN portfolio_hierarchy book WITH (NOLOCK) ON book.entity_id = vw.fas_book_id 
	LEFT JOIN portfolio_hierarchy stra WITH (NOLOCK) ON stra.entity_id = book.parent_entity_id 
	LEFT JOIN portfolio_hierarchy sub WITH (NOLOCK) ON sub.entity_id = stra.parent_entity_id
	LEFT JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = vw.source_deal_detail_id
	LEFT JOIN source_deal_header sdh WITH (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN static_data_value sdv_deal_staus WITH (NOLOCK) ON sdv_deal_staus.value_id = sdh.deal_status
	LEFT JOIN static_data_value sdv_profile WITH (NOLOCK) ON sdv_profile.value_id = sdh.internal_desk_id
	LEFT JOIN static_data_value sdv_confirm WITH (NOLOCK) ON sdv_confirm.value_id = sdh.confirm_status_type
	LEFT JOIN contract_group cg  WITH (NOLOCK) ON cg.contract_id = sdh.contract_id
	left join source_traders tdr on tdr.source_trader_id=sdh.trader_id 
	LEFT JOIN source_uom su  WITH (NOLOCK)ON su.source_uom_id= sdd.deal_volume_uom_id
	LEFT JOIN source_system_book_map ssbm WITH (NOLOCK) ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_book sb1 WITH (NOLOCK) ON sb1.source_book_id = sdh.source_system_book_id1
	LEFT JOIN source_book sb2 WITH (NOLOCK) ON sb2.source_book_id = sdh.source_system_book_id2
	LEFT JOIN source_book sb3 WITH (NOLOCK) ON sb3.source_book_id = sdh.source_system_book_id3
	LEFT JOIN source_book sb4 WITH (NOLOCK) ON sb4.source_book_id = sdh.source_system_book_id4
	LEFT JOIN static_data_value sdv_block WITH (NOLOCK) ON sdv_block.value_id  = sdh.block_define_id
	LEFT JOIN static_data_value sdv_entity WITH (NOLOCK) ON sdv_entity.value_id  = sc.type_of_entity
	LEFT JOIN source_counterparty bkr WITH (NOLOCK) ON bkr.source_counterparty_id = sdh.broker_id 
	left join source_deal_type sdt on sdt.source_deal_type_id=sdh.source_deal_type_id
	left join source_deal_type sdst on sdst.source_deal_type_id=sdh.deal_sub_type_type_id
	LEFT JOIN source_price_curve_def spcd_formula_curve WITH (NOLOCK) ON spcd_formula_curve.source_curve_def_id=isnull(sdd.formula_curve_id,-1)
	LEft join source_currency curr WITH (NOLOCK) on curr.source_currency_id=isnull(sdd.fixed_price_currency_id,sdd.adder_currency_id)
	LEFT JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
		AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
	LEFT  JOIN holiday_group hg ON vw.term_date =  hg.hol_date
			AND CAST(hg.hol_group_value_ID AS VARCHAR(20)) = '''+ ISNULL(@_holiday_calendar_id, -1)+''' '

	+case when  @_summary_option IN ('h','x','y') then '
			LEFT JOIN mv90_DST mv (nolock) ON (vw.[term_date])=(mv.[date])
					AND mv.insert_delete=''i''
					AND vw.[Hours]=25
					AND isnull(tz.dst_group_value_id,-1)= isnull(mv.dst_group_value_id,-1)
			LEFT JOIN mv90_DST mv1 (nolock) ON (vw.[term_date])=(mv1.[date])
				AND mv1.insert_delete=''d''
				AND mv1.Hour=vw.[Hours]		
				AND isnull(tz.dst_group_value_id,-1)= isnull(mv1.dst_group_value_id	,-1)
			LEFT JOIN mv90_DST mv2 (nolock) ON YEAR(vw.[term_date])=(mv2.[YEAR])
				AND mv2.insert_delete=''d''
				AND isnull(tz.dst_group_value_id,-1)= isnull(mv2.dst_group_value_id,-1)
			LEFT JOIN mv90_DST mv3 (nolock) ON YEAR(vw.[term_date])=(mv3.[YEAR])
				AND mv3.insert_delete=''i''
				AND isnull(tz.dst_group_value_id,-1)= isnull(mv3.dst_group_value_id,-1)'


		ELSE '' END
	+ CASE WHEN  @_summary_option IN ('h','x','y') THEN '
		LEFT JOIN #formula_curve_value fcv ON fcv.source_deal_header_id = sdh.source_deal_header_id
			AND vw.term_date = fcv.term_start
			AND fcv.[hr] = CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END
	' ELSE '' END

	+ CASE WHEN  @_summary_option IN ('h','x','y') THEN '
		LEFT JOIN #market_curve_value mcv ON mcv.source_deal_header_id = sdh.source_deal_header_id
			AND vw.term_date = mcv.term_start
			AND mcv.[hr] = CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END
	' ELSE '' END


	
	+ CASE @_summary_option WHEN 'h' THEN '
			LEFT JOIN source_Deal_detail_hour sddh
				ON sdh.internal_desk_id = 17302
				AND sdd.source_deal_detail_id = sddh.source_deal_detail_id
				AND vw.term_date = sddh.term_date
				AND CAST(LEFT(sddh.hr, 2) AS INT)= case when vw.[Hours]=25 then CAST(LEFT(sddh.hr, 2) AS INT) 
             else  ISNULL(mv.Hour, vw.[Hours]) end
    AND sddh.is_dst= case when vw.[Hours]=25 then 1
             else  0 end
	'
			WHEN 'd' THEN '
				OUTER APPLY (
					SELECT max(sddh.price) price
					FROM source_Deal_detail_hour sddh
					WHERE sdh.internal_desk_id = 17302
						AND sdd.source_deal_detail_id = sddh.source_deal_detail_id
						AND vw.term_date = sddh.term_date
				) sddh
			'
			WHEN 'm' THEN '
				OUTER APPLY (
					SELECT max(sddh.price) price
					FROM source_Deal_detail_hour sddh
					WHERE sdh.internal_desk_id = 17302
						AND sdd.source_deal_detail_id = sddh.source_deal_detail_id
						AND LEFT(vw.term_date, 4) = YEAR(sddh.term_date)
						AND RIGHT(vw.term_date, 2) = MONTH(sddh.term_date)
				) sddh
			'
			ELSE ''
	  END
	+case when  @_summary_option IN ('h','x','y') then '
		WHERE  (((vw.[Hours]=25 AND mv.[date] IS NOT NULL) OR (vw.[Hours]<>25)) AND (mv1.[date] IS NULL))'
		+ CASE WHEN @_hour_from IS NOT NULL THEN ' and cast(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END as int) between '+CAST(@_hour_from AS VARCHAR) +' and ' +CAST(@_hour_to AS VARCHAR) ELSE '' END 
	else '' end
	+ '  
	
	CREATE INDEX idx_pos_detail_gas ON #tmp_pos_detail_gas (term)  
	
	'

	
	--PRINT (@_rhpb)
	--PRINT (@_volume_clm)
	--PRINT (@_commodity_str)
	--PRINT (@_rhpb)
	--PRINT (@_volume_clm)
	--PRINT (@_commodity_str1)
	--PRINT (@_rhpb_0)
	--PRINT (@_rhpb1)
	--PRINT(@_rhpb2)
IF OBJECT_ID('tempdb..#final_temp_table') IS NOT NULL
	DROP TABLE #final_temp_table

CREATE TABLE #final_temp_table(
	   [as_of_date] DATE NULL
	 , [sub_id] INT NULL
	 , [stra_id] INT  NULL
	 , [book_id] INT  NULL
	 , [sub] VARCHAR(100) NULL
	 , [strategy]  VARCHAR(100)  NULL
	 , [book] VARCHAR(100)  NULL
	 , [source_deal_header_id] INT  NULL
	 , [deal_id] VARCHAR(100)   NULL
	 , [physical_financial_flag] VARCHAR(100) NULL
	 , [deal_date] DATETIME NULL
	 , [location] VARCHAR(100)  NULL
	 , [index_id] INT NULL
	 , [index] VARCHAR(100) NULL
	 , [proxy_index] VARCHAR(100) NULL
	 , [proxy_index_id] INT NULL
	 , [region] VARCHAR(100) NULL
	 , [region_id] INT NULL
	 , [country] VARCHAR(100)  NULL
	 , [country_id] INT NULL
	 , [grid] VARCHAR(100) NULL
	 , [grid_id] INT NULL
	 , [Province] VARCHAR(100) NULL
	 , [Province_id] INT NULL
	 , [location_group]  VARCHAR(100) NULL
	 , [commodity] VARCHAR(100) NULL
	 , [counterparty_name] VARCHAR(100) NULL
	 , [parent_counterparty] VARCHAR(100) NULL
	 , [book_identifier1] VARCHAR(50) NULL
	 , [book_identifier2] VARCHAR(50) NULL
	 , [book_identifier3] VARCHAR(50) NULL
	 , [book_identifier4] VARCHAR(50) NULL
	 , [book_identifier1_id] INT  NULL
	 , [book_identifier2_id] INT  NULL
	 , [book_identifier3_id] INT  NULL
	 , [book_identifier4_id] INT NULL
	 , [sub_book] VARCHAR(50) NULL
	 , [proxy_curve2] VARCHAR(50) NULL
	 , [proxy2_position_uom] VARCHAR(50) NULL
	 , [proxy_curve3] VARCHAR(50) NULL
	 , [proxy3_position_uom] VARCHAR(50) NULL
	 , [block_definition] VARCHAR(50) NULL
	 , [block_definition_id] INT  NULL
	 , [deal_volume_frequency] VARCHAR(50) NULL
	 , [proxy_curve] VARCHAR(50) NULL
	 , [proxy_curve_id] INT  NULL
	 , [proxy_curve_position_uom] VARCHAR(50) NULL
	 , [counterparty_id] INT  NULL
	 , [location_id] INT  NULL
	 , [proxy_index_position_uom]  VARCHAR(10) NULL
	 , [sub_book_id] INT NULL
	 , [proxy_curve_id3] INT  NULL
	 , [expiration_date] DATE  NULL
	 , [commodity_id] INT  NULL
	 , [block_name] VARCHAR(50) NULL
	 , [block_type_id] INT NULL
	 , [user_defined_block] VARCHAR(50) NULL
	 , [user_defined_block_id] INT  NULL
	 , [block_type_group_id] INT  NULL
	 , [buy_sell_flag] VARCHAR(10) NULL
	 , [Trader] VARCHAR(50) NULL
	 , [Trader_id] INT NULL
	 , [Contract] VARCHAR(50) NULL
	 , [Contract_id] INT  NULL
	 , [Confirm Status] VARCHAR(100) NULL
	 , [confirm_status_id] INT NULL
	 , [Deal Status] VARCHAR(100) NULL
	 , [deal_status_id] INT  NULL
	 , [Profile] VARCHAR(100) NULL
	 , [profile_id] INT NULL
	 , [Deal Volume] NUMERIC(38,17) NULL
	 , [Volume UOM]   VARCHAR(10) NULL
	 , [Scheduled Volume] NUMERIC(38,17) NULL
	 , [Actual Volume]  NUMERIC(38,17) NULL
	 , [term_year] VARCHAR(20) NULL
	 , [term_end] DATE NULL
	 , [term_year_month] VARCHAR(20) NULL
	 , [term_start] DATE NULL
	 , [Position] NUMERIC(38,17) NULL
	 , [uom]  VARCHAR(10) NULL
	 , [postion_uom] VARCHAR(10) NULL
	 , [int_ext_flag] CHAR(5) NULL
	 , [entity_type_id] INT  NULL
	 , [entity_type] VARCHAR(50) NULL
	 , [Broker] VARCHAR(50) NULL
	 , [broker_id] INT NULL
	 , [deal_type_id] INT NULL
	 , [deal_sub_type_id] INT  NULL
	 , [Deal Type] VARCHAR(50) NULL
	 , [Deal Sub Type] VARCHAR(50) NULL
	 , [location_group_id] INT 
	 , [period_from] INT  NULL
	 , [period_to] INT NULL
	 , [Period] INT  NULL
	 , [Hour] INT  NULL
	 , [DST] INT  NULL
	 , [Deal Date From] DATE NULL
	 , [Deal Date To] DATE  NULL
	 , [tenor_option] CHAR(5) NULL
	 , [summary_option] CHAR(5) NULL
	 , [fixed_price] NUMERIC(38,17) NULL
	 , [price_adder] NUMERIC(38,17) NULL
	 , [formula_curve_name] VARCHAR(50) NULL
	 , [price_currency]  VARCHAR(50) NULL
	 , [ext_deal_id]  VARCHAR(50) NULL
	 , [curve_value] FLOAT NULL
	 , [market_curve_value]  FLOAT NULL
	 , [payment_date] DATE NULL
	 , [contract_values] FLOAT  NULL
	 , [adjusted_payment_date_amt] FLOAT NULL
	 , [holiday_calendar_id] VARCHAR(10)  
	 )

	INSERT INTO #final_temp_table	
	EXEC(@_rhpb+@_volume_clm+@_commodity_str+ '; '+@_rhpb+@_volume_clm+ @_commodity_str1 +'; '+@_rhpb_0+@_rhpb1 +@_rhpb2)
	
	
	CREATE INDEX idx_final_temp_table ON #final_temp_table([deal_id], [sub_id], [stra_id], [book_id], [sub])	
	
	SELECT  
	   --@_as_of_date [as_of_date]
	   NULL as_of_date
	 , ftt.[sub_id]
	 , ftt.[stra_id]
	 , ftt.[book_id]
	 , ftt.[sub]
	 , ftt.[strategy]
	 , ftt.[book]
	 , ftt.[source_deal_header_id]
	 , ftt.[deal_id]
	 , ftt.[physical_financial_flag]
	 , ftt.[deal_date]
	 , ftt.[location]
	 , ftt.[index_id]
	 , ftt.[index]
	 , ftt.[proxy_index]
	 , ftt.[proxy_index_id]
	 , ftt.[region]
	 , ftt.[region_id]
	 , ftt.[country]
	 , ftt.[country_id]
	 , ftt.[grid]
	 , ftt.[grid_id]
	 , ftt.[Province]
	 , ftt.[Province_id]
	 , ftt.[location_group]
	 , ftt.[commodity]
	 , ftt.[counterparty_name]
	 , ftt.[parent_counterparty]
	 , ftt.[book_identifier1]
	 , ftt.[book_identifier2]
	 , ftt.[book_identifier3]
	 , ftt.[book_identifier4]
	 , ftt.[book_identifier1_id]
	 , ftt.[book_identifier2_id]
	 , ftt.[book_identifier3_id]
	 , ftt.[book_identifier4_id]
	 , ftt.[sub_book]
	 , ftt.[proxy_curve2]
	 , ftt.[proxy2_position_uom]
	 , ftt.[proxy_curve3]
	 , ftt.[proxy3_position_uom]
	 , ftt.[block_definition]
	 , ftt.[block_definition_id]
	 , ftt.[deal_volume_frequency]
	 , ftt.[proxy_curve]
	 , ftt.[proxy_curve_id]
	 , ftt.[proxy_curve_position_uom]
	 , ftt.[counterparty_id]
	 , ftt.[location_id]
	 , ftt.[proxy_index_position_uom]
	 , ftt.[sub_book_id]
	 , ftt.[proxy_curve_id3]
	 , ftt.[expiration_date]
	 , ftt.[commodity_id]
	 , ftt.[block_name]
	 , ftt.[block_type_id]
	 , ftt.[user_defined_block]
	 , ftt.[user_defined_block_id]
	 , ftt.[block_type_group_id]
	 , ftt.[buy_sell_flag]
	 , ftt.[Trader]
	 , ftt.[Trader_id]
	 , ftt.[Contract]
	 , ftt.[Contract_id]
	 , ftt.[Confirm Status]
	 , ftt.[confirm_status_id]
	 , ftt.[Deal Status]
	 , ftt.[deal_status_id]
	 , ftt.[Profile]
	 , ftt.[profile_id]
	 , ftt.[Deal Volume]
	 , ftt.[Volume UOM]
	 , ftt.[Scheduled Volume]
	 , ftt.[Actual Volume]
	 ,  ftt.[term_year]
	 --, ftt.[term_end]
	 , convert(varchar(10),ftt.[term_end],120) [term_end]
	 , ftt.[term_year_month]
	 , convert(varchar(10),ftt.[term_start],120) [term_start]	
	 --, ftt.[term_start]
     , ftt.[Position]
	 , ftt.[uom]
	 , ftt.[postion_uom]
	 , ftt.[int_ext_flag]
	 , ftt.[entity_type_id]
	 , ftt.[entity_type]
	 , ftt.[Broker]
	 , ftt.[broker_id]
	 , ftt.[deal_type_id]
	 , ftt.[deal_sub_type_id]
	 , ftt.[Deal Type]
	 , ftt.[Deal Sub Type]
	 , ftt.[location_group_id]
	 , ftt.[period_from]
	 , ftt.[period_to]
	 , ftt.[Period]
	 , ftt.[Hour]
	 , ftt.[DST]
	 , ftt.[Deal Date From]
	 , ftt.[Deal Date To]
	 , ftt.[tenor_option]
	 , ftt.[summary_option]
	 , ftt.[fixed_price]
	 , ftt.[price_adder]
	 , ftt.[formula_curve_name]
	 , ftt.[price_currency]
	 , ftt.[ext_deal_id]
	 , ftt.[curve_value]
	 , ftt.[market_curve_value]
	 , ftt.[payment_date]
	 , ftt.[contract_values]
	 , ISNULL(payment_adj.contract_values, 0) [adjusted_payment_date_amt]
	 , null [holiday_calendar_id] --@_holiday_calendar_id 
	 --[__batch_report__]
	 FROM #final_temp_table ftt 
	 OUTER APPLY (
		SELECT ftt1.as_of_date, ftt1.payment_date, ftt1.Hour,SUM(ftt1.contract_values) contract_values
		FROM #final_temp_table ftt1
		WHERE ftt1.as_of_date = ftt.as_of_date
			AND ftt1.payment_date = ftt.term_start
			AND ftt1.Hour = ftt.Hour
			AND ftt1.[source_deal_header_id] = ftt.[source_deal_header_id] 
		GROUP BY ftt1.as_of_date, ftt1.payment_date, ftt1.Hour
      ) payment_adj