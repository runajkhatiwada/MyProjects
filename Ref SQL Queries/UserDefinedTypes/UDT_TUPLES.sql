IF TYPE_ID(N'dbo.UDT_TUPLES') IS NOT NULL
	DROP TYPE dbo.UDT_TUPLES
GO

CREATE TYPE dbo.UDT_TUPLES AS TABLE (
	id VARCHAR(50), 
	val VARCHAR(1000)
)  
GO 