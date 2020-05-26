;WITH x AS 
(
  SELECT x FROM (VALUES('0'),('1')) AS y(x)
)
SELECT 
       [binary] = x.x + x2.x + x3.x + x4.x + x5.x-- + x6.x
FROM x
CROSS JOIN x AS x2
CROSS JOIN x AS x3
CROSS JOIN x AS x4
CROSS JOIN x AS x5
--CROSS JOIN x AS x6

order by 1