DECLARE @deal_ids VARCHAR(MAX) = '44193,44195,37231,37232,37234,37235,37236,39742,39743,39744,39745,39746,39747,39748,39750,39752,39754,39756,39758,39760,39762,39764,39766,39768,42909,42910,42911,42912,42913,42914,42915,42916,42917,42918,42919,42920,42921,42922,42923,42924,42925,42926,42927,42928,42929,42930,42931,42932,42933,42934,42935,42936,42937,42938,42939,42940,42941,42942,42943,42944,42945,42946,42947,42948,42949,42950,42951,42952,42953,42954,42955,42956,42957,42958,42959,42960,42961,42962,42963,42964,42965,42966,42967,42968,42969,42970,42971,42972,42973,42974,42975,42976,42977,42978,42979,42980,42981,42982,42983,42984,42985,42986,42987,42988,42989,42990,42991,42992,42993,42994,42995,42996,42997,42998,42999,43000,43001,43002,43003,43004,43005,43006,43007,43008,43009,43010,43011,43012,43013,43014,43015,43016,43017,43018,43019,43020,43021,43022,43023,43024,43025,43026,43027,43028,43029,43030,43031,43032,43033,43034,43035,43036,43037,43038,43039,43040,43041,43042,43043,43044,43045,43046,43047,43048,43049,43050,43051,43052,43053,43054,43055,43056,43057,43058,43059,43060,43061,43062,43063,43064,43065,43066,43067,43068,43069,43070,43071,43072,43073,43074,43075,43076,43077,43078,43079,43080,43081,43082,43083,43084,43085,43086,43087,43088,43089,43090,43091,43092,43093,43094,43095,43096,43097,43098,43099,43100,43101,43102,43103,43104,43105,43106,43107,43108,43109,43110,43111,43112,43113,43114,43115,43116,43117,43118,43119,43120,43121,43122,43123,43124,43125,43126,43127,43128,43129,43130,43131,43132,43133,43134,43135,43136,43137,43138,43139,43140,43141,43142,43143,43144,43145,43146,43147,43148,43186,43187,44190,44191,44192,44194,44201,44202,44250,44251,44252,44253,44254,56367,57594,57713,37233,39763,39765,39767,44282'

IF OBJECT_ID('tempdb..#source_deal_header_temp') IS NOT NULL
	DROP TABLE #source_deal_header_temp
	
CREATE TABLE #source_deal_header_temp (
	source_deal_header_id INT
)

INSERT INTO #source_deal_header_temp
SELECT * FROM dbo.SplitCommaSeperatedValues(@deal_ids)

SELECT assign.*
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN assignment_audit assign
	ON assign.source_deal_header_id = sdd.source_deal_detail_id
INNER JOIN #source_deal_header_temp d
	ON sdh.source_deal_header_id = d.source_deal_header_id
    
		
SELECT unassign.*
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN unassignment_audit unassign
	ON unassign.source_deal_header_id = sdd.source_deal_detail_id
INNER JOIN #source_deal_header_temp d
	ON sdh.source_deal_header_id = d.source_deal_header_id
    
		
SELECT g.*
FROM gis_certificate g
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_detail_id = g.source_deal_header_id
INNER JOIN #source_deal_header_temp d
	ON sdd.source_deal_header_id = d.source_deal_header_id
     
SELECT g.*
FROM deal_exercise_detail g
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_detail_id = g.source_deal_detail_id
INNER JOIN #source_deal_header_temp d
	ON sdd.source_deal_header_id = d.source_deal_header_id
    
SELECT g.*
FROM confirm_status_recent g
INNER JOIN #source_deal_header_temp d
	ON g.source_deal_header_id = d.source_deal_header_id

SELECT g.*
FROM confirm_status g
INNER JOIN #source_deal_header_temp d
	ON g.source_deal_header_id = d.source_deal_header_id
		
SELECT g.*
FROM first_day_gain_loss_decision g
INNER JOIN #source_deal_header_temp d
	ON g.source_deal_header_id = d.source_deal_header_id

SELECT g.*
FROM deal_tagging_audit g
INNER JOIN #source_deal_header_temp d
	ON g.source_deal_header_id = d.source_deal_header_id

IF OBJECT_ID('tempdb..#tmp_gen_hedge_group_id') IS NOT NULL
	DROP TABLE #tmp_gen_hedge_group_id	

SELECT ghg.[gen_hedge_group_id] 
INTO #tmp_gen_hedge_group_id
FROM gen_hedge_group ghg
INNER JOIN gen_fas_link_header gflh
ON ghg.[gen_hedge_group_id] = gflh.[gen_hedge_group_id]
INNER JOIN gen_fas_link_detail gfld
ON gflh.gen_link_id = gfld.gen_link_id
INNER JOIN #source_deal_header_temp dd
ON gfld.deal_number = dd.source_deal_header_id

SELECT d.*
FROM gen_transaction_status d
INNER JOIN #tmp_gen_hedge_group_id f
	ON d.gen_hedge_group_id = f.gen_hedge_group_id
	
SELECT d.*
FROM gen_fas_link_detail_dicing d
INNER JOIN gen_fas_link_header z
	ON d.link_id = z.gen_link_id
INNER JOIN #tmp_gen_hedge_group_id f
	ON f.gen_hedge_group_id = z.gen_hedge_group_id

SELECT d.*
FROM gen_fas_link_detail d
INNER JOIN gen_fas_link_header z
	ON d.gen_link_id = z.gen_link_id
INNER JOIN #tmp_gen_hedge_group_id f
	ON f.gen_hedge_group_id = z.gen_hedge_group_id

SELECT d.*
FROM gen_fas_link_header d
INNER JOIN #tmp_gen_hedge_group_id f
	ON d.gen_hedge_group_id = f.gen_hedge_group_id

SELECT d.*
FROM gen_hedge_group_detail d
INNER JOIN #tmp_gen_hedge_group_id f
	ON d.gen_hedge_group_id = f.gen_hedge_group_id

SELECT d.*
FROM gen_hedge_group d
INNER JOIN #tmp_gen_hedge_group_id f
	ON d.gen_hedge_group_id = f.gen_hedge_group_id

SELECT s.*
FROM user_defined_deal_fields s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
		
SELECT d.*
FROM user_defined_deal_detail_fields s
INNER JOIN source_deal_detail sdd
	ON s.source_deal_detail_id = sdd.source_deal_detail_id
INNER JOIN source_deal_header sdh
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN #source_deal_header_temp d
	ON sdh.source_deal_header_id = d.source_deal_header_id
		
--UPDATE dvie
--SET tran_status = 'd'
--FROM deal_voided_in_external dvie
--INNER JOIN #source_deal_header_temp d
--	ON dvie.source_deal_header_id = d.source_deal_header_id
	
SELECT s.*
FROM source_deal_pnl_eff s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
	
SELECT s.*
FROM source_deal_pnl_settlement s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
		
SELECT s.*
FROM source_deal_pnl_arch2 s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id --Nondelete deal backup 
	
SELECT s.*
FROM source_deal_pnl_arch1 s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
		
SELECT s.*
FROM source_deal_pnl s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
	
SELECT s.*
FROM deal_position_break_down s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
	
SELECT s.*
FROM source_deal_detail s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
		
SELECT s.*
FROM source_deal_header s
INNER JOIN #source_deal_header_temp d
	ON s.source_deal_header_id = d.source_deal_header_id
		
return
EXEC spa_ErrorHandler 0
	, 'Delete_Deals_Links'
	, 'spa_delete_deals_links_mtm'
	, 'Success'
	, 'Successfully deleted.'
	, ''