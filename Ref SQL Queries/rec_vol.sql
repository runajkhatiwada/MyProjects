--if object_id ('tempdb..#temp') is not null
--	drop table #temp

--create table #temp (
--	deal_id varchar(255),
--	term_date varchar(20),
--	forecast_volume numeric(38, 20),
--	actual_volume numeric(38, 20)
--)

--insert into #temp 
--SELECT 'Import test','1/1/2018',200,150 UNION ALL
--SELECT 'Import test','2/1/2018',200,150 UNION ALL
--SELECT 'Import test','3/1/2018',200,150 UNION ALL
--SELECT 'Import test','4/1/2018',200,150 UNION ALL
--SELECT 'Import test','5/1/2018',200,150 UNION ALL
--SELECT 'Import test','6/1/2018',200,150
--here, sdd.actual_volume is certified vol, sdd.schedule_volume is actual vol and sdd.contractual_volume is forecast vol
update sdd
set sdd.contractual_volume = a.forecast_volume,
	sdd.schedule_volume = a.actual_volume,
	sdd.deal_volume = coalesce(sdd.actual_volume, a.actual_volume, a.forecast_volume)
from #temp a
inner join source_deal_header sdh
	on sdh.deal_id = a.deal_id
inner join source_deal_detail sdd
	on sdd.source_deal_header_id = sdh.source_deal_header_id
where sdd.term_start = convert(datetime, convert(varchar(10), a.term_date, 103), 120)

update sdd
set sdd.volume_left = (sdd.deal_volume - ISNULL(sdd.volume_left, 0))
from #temp a
inner join source_deal_header sdh
	on sdh.deal_id = a.deal_id
inner join source_deal_detail sdd
	on sdd.source_deal_header_id = sdh.source_deal_header_id
where sdd.term_start = convert(datetime, convert(varchar(10), a.term_date, 103), 120)

declare @source_deal_header_ids varchar(max)

select @source_deal_header_ids = isnull(@source_deal_header_ids + ',', '') + cast(source_deal_header_id as varchar(10))
from(
select DISTINCT sdh.source_deal_header_id
from #temp a
inner join source_deal_header sdh
	on sdh.deal_id = a.deal_id
) b


EXEC [dbo].[spa_update_deal_total_volume] @source_deal_header_ids = @source_deal_header_ids

