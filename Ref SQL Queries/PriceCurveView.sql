DECLARE @_sql VARCHAR(MAX),
        @_to_as_of_date VARCHAR(25),
        @_as_of_date VARCHAR(25) = '@as_of_date',
        @_from_maturity_date VARCHAR(25),
        @_to_maturity_date VARCHAR(25),
        @_period_from VARCHAR(25),
        @_period_to VARCHAR(25),
        @_curve_id VARCHAR(MAX),
		@_granularity INT

IF '@to_as_of_date' <> 'NULL'
	 SET @_to_as_of_date = '@to_as_of_date'
   
IF '@granularity' <> 'NULL'
	 SET @_granularity = '@granularity'

IF '@to_maturity_date' <> 'NULL'
	 SET @_to_maturity_date = '@to_maturity_date'
   
IF '@maturity_date' <> 'NULL'
	 SET @_from_maturity_date = '@maturity_date'
   
IF '@period_from' <> 'NULL'
	 SET @_period_from = CONVERT(VARCHAR(10), dbo.FNAGetTermStartDate('m', @_as_of_date, '@period_from'), 120)
   
IF '@period_to' <> 'NULL'
	 SET @_period_to = CONVERT(VARCHAR(10), dbo.FNAGetTermENDDate('m', @_as_of_date, '@period_to'), 120)
   
IF '@curve_id' <> 'NULL'
	SET @_curve_id = '@curve_id'

IF (@_from_maturity_date IS NOT NULL AND @_period_from IS NOT NULL) OR (@_to_maturity_date IS NOT NULL AND @_period_to IS NOT NULL)
BEGIN
	IF DATEDIFF(dd, ISNULL(@_period_from, @_from_maturity_date), ISNULL(@_from_maturity_date, @_period_from)) >= 0
		SET @_from_maturity_date = ISNULL(@_from_maturity_date, @_period_from)
	ELSE
		SET @_from_maturity_date = @_period_from
	IF DATEDIFF(dd, ISNULL(@_period_to, @_to_maturity_date), ISNULL(@_to_maturity_date, @_period_to)) >= 0
		SET @_to_maturity_date = ISNULL(@_period_to, @_to_maturity_date)
	ELSE
		SET @_to_maturity_date = @_to_maturity_date
END
ELSE
BEGIN
	IF @_from_maturity_date IS NULL AND @_period_from IS NOT NULL
		SET @_from_maturity_date = @_period_from

	IF @_to_maturity_date IS NULL AND @_period_to IS NOT NULL
		SET @_to_maturity_date = @_period_to
END

SET @_sql = '
	SELECT spc.source_curve_def_id [curve_id],
		   spcd.curve_id [curve_code],
		   spc.as_of_date,
		   spc.as_of_date [to_as_of_date],
		   spc.maturity_date,
		   spc.maturity_date [to_maturity_date],
		   spc.curve_value,
		   spc.bid_value,
		   spc.ask_value,
		   spc.is_dst,
		   spcd.curve_name,
		   spc.curve_source_value_id,
		   sdv_curve_source.code,
		   spc.Assessment_curve_type_value_id,
		   spcd.Granularity,
		   DAY(spc.maturity_date) [maturity_day],
		   RIGHT(''0'' + CAST(MONTH(spc.maturity_date) AS varchar(2)), 2) [maturity_month],
		   DATENAME(m, spc.maturity_date) [maturity_month_name],
		   YEAR(spc.maturity_date) [maturity_year],
		   CAST(YEAR(spc.maturity_date) AS varchar(5)) + ''-'' + RIGHT(''0'' + CAST(MONTH(spc.maturity_date) AS varchar(2)), 2) [maturity_year_month],
		   ''Q'' + CAST(DATEPART(q, spc.maturity_date) AS varchar) [maturity_quarter],
		   sdv_assessment_curve_type.code [assessment_curve_type],
		   DATEPART(HH, maturity_date) [hour],
		   DATEPART(MINUTE, maturity_date) [minute],
		   ''@period_from'' [period_from],
		   ''@period_to'' [period_to],
		   spcd.forward_settle,
		   spcd.commodity_id
	--[__batch_report__]
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = spc.source_curve_def_id
	LEFT JOIN static_data_value sdv_curve_source
		ON sdv_curve_source.value_id = spc.curve_source_value_id
	LEFT JOIN static_data_value sdv_assessment_curve_type
		ON sdv_assessment_curve_type.value_id = spc.Assessment_curve_type_value_id
	WHERE 1 = 1
' + 
CASE WHEN @_to_as_of_date IS NULL THEN 'AND spc.as_of_date = ''' + @_as_of_date + ''''
	 ELSE 'AND spc.as_of_date >= ''' + @_as_of_date + ''' AND spc.as_of_date <= ''' + @_to_as_of_date + ''''
END 
+
CASE WHEN @_from_maturity_date IS NULL AND @_to_maturity_date IS NULL THEN ''
	 WHEN @_from_maturity_date IS NULL THEN 'AND spc.maturity_date < DATEADD(dd,1,''' + @_to_maturity_date + ''')'
	 WHEN @_to_maturity_date IS NULL THEN 'AND spc.maturity_date >= ''' + @_from_maturity_date + ''''
	 ELSE 'AND spc.maturity_date >= ''' + @_from_maturity_date + ''' AND spc.maturity_date < DATEADD(dd,1,''' + @_to_maturity_date + ''')'
END
+
CASE WHEN @_period_from IS NULL AND @_period_to IS NULL THEN ''
	 WHEN @_period_from IS NULL THEN 'AND MONTH(spc.maturity_date) < MONTH(''' + @_period_to + ''')'
	 WHEN @_period_to IS NULL THEN 'AND MONTH(spc.maturity_date) >= MONTH(''' + @_period_from + ''')'
	 ELSE 'AND MONTH(spc.maturity_date) BETWEEN MONTH(''' + @_period_from + ''') AND MONTH(''' + @_period_to + ''')'
END
+
CASE WHEN @_curve_id IS NOT NULL THEN ' AND spc.source_curve_def_id IN(' + @_curve_id + ')'
	 ELSE ''
END
+
CASE WHEN @_granularity IS NOT NULL THEN ' AND spcd.Granularity = ' + CAST(@_granularity AS VARCHAR(10)) + ''
	 ELSE ''
END

EXEC (@_sql)
