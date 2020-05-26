declare @job_id varchar(8000), @sql_string varchar(max)=''

select @job_id = isnull(@job_id + ',', '') + cast(job_id as varchar(100))
from msdb.dbo.sysjobs_view where SUSER_SNAME(owner_sid) = 'runaj' 

SELECT 'EXEC msdb.dbo.sp_delete_job @job_id=''' + item + '''; '
FROM dbo.SplitCommaSeperatedValues(@job_id)
--dbcc opentran
--kill 155

EXEC msdb.dbo.sp_delete_job @job_id='44853F88-8D91-42E4-B35B-FA44733EDF84'; 