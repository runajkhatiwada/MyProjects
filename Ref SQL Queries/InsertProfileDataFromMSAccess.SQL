/* Enable Triggers to set all the staging table read only
IF OBJECT_ID(N'Trigger_Pioneer_Upload_LCI_Interval', N'TR') IS NOT NULL
	DROP TRIGGER Trigger_Pioneer_Upload_LCI_Interval
GO

CREATE TRIGGER Trigger_Pioneer_Upload_LCI_Interval ON Tbl_Pioneer_Upload_LCI_Interval
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'Tbl_Pioneer_Upload_LCI_Interval table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END
GO

IF OBJECT_ID(N'Trigger_Pioneer_Upload_LCI_Profiled', N'TR') IS NOT NULL
	DROP TRIGGER Trigger_Pioneer_Upload_LCI_Profiled
GO

CREATE TRIGGER Trigger_Pioneer_Upload_LCI_Profiled ON Tbl_Pioneer_Upload_LCI_Profiled
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'Tbl_Pioneer_Upload_LCI_Profiled table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END
GO

IF OBJECT_ID(N'Trigger_Pioneer_Profile_Upload', N'TR') IS NOT NULL
	DROP TRIGGER Trigger_Pioneer_Profile_Upload
GO

CREATE TRIGGER Trigger_Pioneer_Profile_Upload ON Tbl_Pioneer_Profile_Upload
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'Tbl_Pioneer_Profile_Upload table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END
GO

IF OBJECT_ID(N'Trigger_Pioneer_Profile_Upload_1', N'TR') IS NOT NULL
	DROP TRIGGER Trigger_Pioneer_Profile_Upload_1
GO

CREATE TRIGGER Trigger_Pioneer_Profile_Upload_1 ON Tbl_Pioneer_Profile_Upload_1
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'Tbl_Pioneer_Profile_Upload_1 table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END
GO
*/
IF OBJECT_ID('adiha_process..temp_profile_data') IS NOT NULL
	DROP TABLE adiha_process.dbo.temp_profile_data

CREATE TABLE adiha_process.dbo.temp_profile_data (
	[profile_name] VARCHAR(5000), 
	[term] DATE, 
	[hour] INT,
	[minute] INT, 
	[volume] NUMERIC(38, 20),
	[is_dst] INT
)

INSERT INTO adiha_process.dbo.temp_profile_data ([profile_name], [term], [hour], [minute], [volume], [is_dst])
SELECT * 
FROM (
	SELECT [Profile_Name], [Term], [Hour], [Minute], [Volume], [is Dst] FROM Tbl_Pioneer_Upload_LCI_Interval UNION  																											 
	SELECT [Profile_Name], [Term], [Hour], [Minute], [Volume], [is Dst] FROM Tbl_Pioneer_Upload_LCI_Profiled UNION  																								 
	SELECT [Profile_Name], [Term], [Hour], [Minute], [Volume], [is Dst] FROM Tbl_Pioneer_Profile_Upload UNION  																								 
	SELECT [Profile_Name], [Term], [Hour], [Minute], [Volume], [is Dst] FROM Tbl_Pioneer_Profile_Upload_1		 
) z
	

BEGIN TRY
	BEGIN TRANSACTION
	INSERT INTO udt_customer_hourly_volume_info (
		hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15,
		hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24, hr25, term_date, [uid]
	)
	SELECT ISNULL([1], 0) hr1, ISNULL([2], 0) hr2, ISNULL([3], 0) hr3, ISNULL([4], 0) hr4, ISNULL([5], 0) hr5, ISNULL([6], 0) hr6, ISNULL([7], 0) hr7, ISNULL([8], 0) hr8,
		   ISNULL([9], 0) hr9, ISNULL([10], 0) hr10, ISNULL([11], 0) hr11, ISNULL([12], 0) hr12, ISNULL([13], 0) hr13, ISNULL([14], 0) hr14, ISNULL([15], 0) hr15,
		   ISNULL([16], 0) hr16, ISNULL([17], 0) hr17, ISNULL([18], 0) hr18, ISNULL([19], 0) hr19, ISNULL([20], 0) hr20, ISNULL([21], 0) hr21, ISNULL([22], 0) hr22,
		   ISNULL([23], 0) hr23, ISNULL([24], 0) hr24, [25] hr25, [term] term_date, profile_name [uid]
	FROM
	(	
		SELECT tpd.[profile_name], 
			   tpd.[term],
			   IIF(tpd.[minute] IS NULL, 25, tpd.[hour]) [hour],
			   ISNULL(tpd.[minute], 0) [minute],
			   tpd.[volume]
 		FROM adiha_process.dbo.temp_profile_data tpd
	) p
	PIVOT (MAX(volume) FOR [hour] IN (
			[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13],
			[14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]
		)
	) AS pvt

	SELECT @@ROWCOUNT [Total Inserted Rows]
	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		   ROLLBACK

	SELECT ERROR_MESSAGE() Error
END CATCH
GO