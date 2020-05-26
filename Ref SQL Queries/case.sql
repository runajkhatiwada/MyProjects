--update source_mifid_audit_log 
--set response_status = 'ACPT'
--where source_mifid_audit_log_id=5235

select top 2* from source_mifid_audit_log where deal_id = '4591000' order by 1 desc

--update source_mifid
--set report_status = 'CANC'
--where source_mifid_id=22981

select top 2* from source_mifid where deal_id = '4591000' order by 1 desc
select deal_status,*  from source_deal_header where deal_id = '4591000' 
--update source_deal_header
--set deal_status = 5607
--where source_deal_header_id = 3330 
--5606 Amended
--5607 Cancelled
--5604 New


