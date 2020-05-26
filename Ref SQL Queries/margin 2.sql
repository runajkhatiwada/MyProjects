--insert into margin_payment_info (counterparty_id,
--payment_date,
--payment_amount,
--currency,
--payment_status)
--values ('A00204', '2017-11-21', 10000, 'EUR', 'y')
--insert into margin_payment_info (counterparty_id,
--payment_date,
--payment_amount,
--currency,
--payment_status)
--values ('A00228', '2017-11-21', 10000, 'EUR', 'y')
insert into margin_payment_info (counterparty_id,
payment_date,
payment_amount,
currency,
payment_status)
values ('A00184', '2017-11-21', 5000, 'EUR', 'y')

--select * from margin_payment_info
declare @_counterparty_id varchar(max) = '5705,4574,4575'
SELECT source_counterparty_id, COUNT(mpi.counterparty_id)
FROM margin_payment_info mpi
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = mpi.counterparty_id
INNER JOIN dbo.SplitCommaSeperatedValues(@_counterparty_id) t
	ON sc.source_counterparty_id = t.item
GROUP BY source_counterparty_id


