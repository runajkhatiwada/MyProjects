--drop table covid_case_details 
create table covid_case_details (
	covid_case_details_id INT identity(1,1),
	[date] DATE, 
	[day] INT, 
	[month] INT, 
	[year] INT, 
	[cases] INT, 
	[deaths] INT, 
	[country] VARCHAR(5000), 
	[code] VARCHAR(10), 
	[population] INT, 
	[cases_cum] INT,	
	[deaths_cum] INT

)

insert into covid_case_details(
date
,day
,month
,year
,cases
,deaths
,country
,code
,population
,cases_cum
,deaths_cum
)
select date
,day
,month
,year
,cases
,deaths
,country
,code
,population
,cases_cum
,deaths_cum from dummy
select * from covid_case_details


--create table iso_code_detail (
--	iso_code CHAR(2),
--	country_name VARCHAR(100),
--	country_name_map VARCHAR(100)
--)
/*
truncate table iso_code_detail 
INSERT INTO iso_code_detail (country_name, iso_code)
SELECT 'Austria', 'AT' UNION ALL
SELECT 'Bangladesh', 'BD' UNION ALL
SELECT 'Belarus', 'BY' UNION ALL
SELECT 'Belgium', 'BE' UNION ALL
SELECT 'Brazil ', 'BR' UNION ALL
SELECT 'Canada ', 'CA' UNION ALL
SELECT 'Chile', 'CL' UNION ALL
SELECT 'China', 'CN' UNION ALL
SELECT 'Colombia', 'CO' UNION ALL
SELECT 'Denmark', 'DK' UNION ALL
SELECT 'Dominican Republic ', 'DO' UNION ALL
SELECT 'Ecuador', 'EC' UNION ALL
SELECT 'Egypt', 'EG' UNION ALL
SELECT 'France ', 'FR' UNION ALL
SELECT 'Germany', 'DE' UNION ALL
SELECT 'India', 'IN' UNION ALL
SELECT 'Indonesia ', 'ID' UNION ALL
SELECT 'Iran', 'IR' UNION ALL
SELECT 'Ireland', 'IE' UNION ALL
SELECT 'Israel ', 'IL' UNION ALL
SELECT 'Italy', 'IT' UNION ALL
SELECT 'Japan', 'JP' UNION ALL
SELECT 'South Korea', 'KR' UNION ALL
SELECT 'Kuwait', 'KW' UNION ALL
SELECT 'Mexico', 'MX' UNION ALL
SELECT 'Netherlands', 'NL' UNION ALL
SELECT 'Pakistan', 'PK' UNION ALL
SELECT 'Peru', 'PE' UNION ALL
SELECT 'Philippines', 'PH' UNION ALL
SELECT 'Poland', 'PL' UNION ALL
SELECT 'Portugal', 'PT' UNION ALL
SELECT 'Qatar', 'QA' UNION ALL
SELECT 'Romania', 'RO' UNION ALL
SELECT 'Russian Federation', 'RU' UNION ALL
SELECT 'Saudi Arabia', 'SA' UNION ALL
SELECT 'Serbia', 'RS' UNION ALL
SELECT 'Singapore', 'SG' UNION ALL
SELECT 'South Africa', 'ZA' UNION ALL
SELECT 'Spain', 'ES' UNION ALL
SELECT 'Sweden', 'SE' UNION ALL
SELECT 'Switzerland', 'CH' UNION ALL
SELECT 'Turkey', 'TR' UNION ALL
SELECT 'Ukraine', 'UA' UNION ALL
SELECT 'United Arab Emirates', 'AE' UNION ALL
SELECT 'United Kingdom', 'GB' UNION ALL
SELECT 'United States', 'US'
*/