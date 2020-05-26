IF OBJECT_ID ('tempdb..#char_mapping') IS NOT NULL
	DROP TABLE #char_mapping

CREATE TABLE #char_mapping (
	special_char NCHAR(1),
	normal_char CHAR(1)
)
IF OBJECT_ID ('tempdb..#input_chars') IS NOT NULL
	DROP TABLE #input_chars

CREATE TABLE #input_chars (
	input_chars NCHAR(1)
)
INSERT INTO #char_mapping
SELECT N'Ä', 'A' UNION ALL 
SELECT N'ä', 'A' UNION ALL
SELECT N'À', 'A' UNION ALL
SELECT N'à', 'A' UNION ALL
SELECT N'Á', 'A' UNION ALL
SELECT N'á', 'A' UNION ALL
SELECT N'Â', 'A' UNION ALL
SELECT N'â', 'A' UNION ALL
SELECT N'Ã', 'A' UNION ALL
SELECT N'ã', 'A' UNION ALL
SELECT N'Å', 'A' UNION ALL
SELECT N'å', 'A' UNION ALL
SELECT N'Ǎ', 'A' UNION ALL
SELECT N'ǎ', 'A' UNION ALL
SELECT N'Ą', 'A' UNION ALL
SELECT N'ą', 'A' UNION ALL
SELECT N'Ă', 'A' UNION ALL
SELECT N'ă', 'A' UNION ALL
SELECT N'Æ', 'A' UNION ALL
SELECT N'æ', 'A' UNION ALL
SELECT N'Ç', 'C' UNION ALL
SELECT N'ç', 'C' UNION ALL
SELECT N'Ć', 'C' UNION ALL
SELECT N'ć', 'C' UNION ALL
SELECT N'Ĉ', 'C' UNION ALL
SELECT N'ĉ', 'C' UNION ALL
SELECT N'Č', 'C' UNION ALL
SELECT N'č', 'C' UNION ALL
SELECT N'Ď', 'D' UNION ALL
SELECT N'đ', 'D' UNION ALL
SELECT N'Đ', 'D' UNION ALL
SELECT N'ď', 'D' UNION ALL
SELECT N'ð', 'D' UNION ALL
SELECT N'È', 'E' UNION ALL
SELECT N'è', 'E' UNION ALL
SELECT N'É', 'E' UNION ALL
SELECT N'é', 'E' UNION ALL
SELECT N'Ê', 'E' UNION ALL
SELECT N'ê', 'E' UNION ALL
SELECT N'Ë', 'E' UNION ALL
SELECT N'ë', 'E' UNION ALL
SELECT N'Ě', 'E' UNION ALL
SELECT N'ě', 'E' UNION ALL
SELECT N'Ę', 'E' UNION ALL
SELECT N'ę', 'E' UNION ALL
SELECT N'Ĝ', 'G' UNION ALL
SELECT N'ĝ', 'G' UNION ALL
SELECT N'Ģ', 'G' UNION ALL
SELECT N'ģ', 'G' UNION ALL
SELECT N'Ğ', 'G' UNION ALL
SELECT N'ğ', 'G' UNION ALL
SELECT N'Ĥ', 'H' UNION ALL
SELECT N'ĥ', 'H' UNION ALL
SELECT N'Ì', 'I' UNION ALL
SELECT N'ì', 'I' UNION ALL
SELECT N'Í', 'I' UNION ALL
SELECT N'í', 'I' UNION ALL
SELECT N'Î', 'I' UNION ALL
SELECT N'î', 'I' UNION ALL
SELECT N'Ï', 'I' UNION ALL
SELECT N'ï', 'I' UNION ALL
SELECT N'ı', 'I' UNION ALL
SELECT N'Ĵ', 'J' UNION ALL
SELECT N'ĵ', 'J' UNION ALL
SELECT N'Ķ', 'K' UNION ALL
SELECT N'ķ', 'K' UNION ALL
SELECT N'Ĺ', 'L' UNION ALL
SELECT N'ĺ', 'L' UNION ALL
SELECT N'Ļ', 'L' UNION ALL
SELECT N'ļ', 'L' UNION ALL
SELECT N'Ł', 'L' UNION ALL
SELECT N'ł', 'L' UNION ALL
SELECT N'Ľ', 'L' UNION ALL
SELECT N'ľ', 'L' UNION ALL
SELECT N'Ñ', 'N' UNION ALL
SELECT N'ñ', 'N' UNION ALL
SELECT N'Ń', 'N' UNION ALL
SELECT N'ń', 'N' UNION ALL
SELECT N'Ň', 'N' UNION ALL
SELECT N'ň', 'N' UNION ALL
SELECT N'Ö', 'O' UNION ALL
SELECT N'ö', 'O' UNION ALL
SELECT N'Ò', 'O' UNION ALL
SELECT N'ò', 'O' UNION ALL
SELECT N'Ó', 'O' UNION ALL
SELECT N'ó', 'O' UNION ALL
SELECT N'Ô', 'O' UNION ALL
SELECT N'ô', 'O' UNION ALL
SELECT N'Õ', 'O' UNION ALL
SELECT N'õ', 'O' UNION ALL
SELECT N'Ő', 'O' UNION ALL
SELECT N'ő', 'O' UNION ALL
SELECT N'Ø', 'O' UNION ALL
SELECT N'ø', 'O' UNION ALL
SELECT N'Œ', 'O' UNION ALL
SELECT N'œ', 'O' UNION ALL
SELECT N'Ŕ', 'R' UNION ALL
SELECT N'ŕ', 'R' UNION ALL
SELECT N'Ř', 'R' UNION ALL
SELECT N'ř', 'R' UNION ALL
SELECT N'ẞ', 'S' UNION ALL
SELECT N'ß', 'S' UNION ALL
SELECT N'Ś', 'S' UNION ALL
SELECT N'ś', 'S' UNION ALL
SELECT N'Ŝ', 'S' UNION ALL
SELECT N'ŝ', 'S' UNION ALL
SELECT N'Ş', 'S' UNION ALL
SELECT N'ş', 'S' UNION ALL
SELECT N'Š', 'S' UNION ALL
SELECT N'š', 'S' UNION ALL
SELECT N'Ș', 'S' UNION ALL
SELECT N'ș', 'S' UNION ALL
SELECT N'Ť', 'T' UNION ALL
SELECT N'ť', 'T' UNION ALL
SELECT N'Ţ', 'T' UNION ALL
SELECT N'ţ', 'T' UNION ALL
SELECT N'Þ', 'T' UNION ALL
SELECT N'þ', 'T' UNION ALL
SELECT N'Ț', 'T' UNION ALL
SELECT N'ț', 'T' UNION ALL
SELECT N'Ü', 'U' UNION ALL
SELECT N'ü', 'U' UNION ALL
SELECT N'Ù', 'U' UNION ALL
SELECT N'ù', 'U' UNION ALL
SELECT N'Ú', 'U' UNION ALL
SELECT N'ú', 'U' UNION ALL
SELECT N'Û', 'U' UNION ALL
SELECT N'û', 'U' UNION ALL
SELECT N'Ű', 'U' UNION ALL
SELECT N'ű', 'U' UNION ALL
SELECT N'Ũ', 'U' UNION ALL
SELECT N'ũ', 'U' UNION ALL
SELECT N'Ų', 'U' UNION ALL
SELECT N'ų', 'U' UNION ALL
SELECT N'Ů', 'U' UNION ALL
SELECT N'ů', 'U' UNION ALL
SELECT N'Ŵ', 'W' UNION ALL
SELECT N'ŵ', 'W' UNION ALL
SELECT N'Ý', 'Y' UNION ALL
SELECT N'ý', 'Y' UNION ALL
SELECT N'Ÿ', 'Y' UNION ALL
SELECT N'ÿ', 'Y' UNION ALL
SELECT N'Ŷ', 'Y' UNION ALL
SELECT N'ŷ', 'Y' UNION ALL
SELECT N'Ź', 'Z' UNION ALL
SELECT N'ź', 'Z' UNION ALL
SELECT N'Ž', 'Z' UNION ALL
SELECT N'ž', 'Z' UNION ALL
SELECT N'Ż', 'Z' UNION ALL
SELECT N'ż', 'Z'

DECLARE @input NVARCHAR(MAX) = 'ĹÌļ***AĜÈ1ERdasdk@##'

--INSERT INTO #input_chars
--SELECT input_char
--FROM (
--	SELECT ns.n pos, 
--			SUBSTRING(ss.s, ns.n, 1) input_char
--	FROM (SELECT @input s) AS ss
--	CROSS JOIN (SELECT n 
--				FROM seq  WHERE n <= LEN(@input)
--				) ns
	
--) pairs

--DECLARE @output VARCHAR(20)
--SELECT @output = ISNULL(@output, '') + isnull(iif(normal_char is not null, replace(input_chars, input_chars, normal_char), normal_char), input_chars)
--FROM #char_mapping a
--RIGHT JOIN #input_chars b
--ON unicode(a.special_char)=unicode(b.input_chars)
--where b.input_chars is not null

--SELECT @output

--SELECT *--isnull(iif(normal_char is not null, replace(input_chars, input_chars, normal_char), normal_char), input_chars)
--FROM #char_mapping a
--RIGHT JOIN #input_chars b
--ON unicode(a.special_char)=unicode(b.input_chars)
--where b.input_chars is not null
--and (input_chars like '%[a-z]%' or input_chars like '%[0-9]%')

--DECLARE @input NVARCHAR(MAX) = 'ĹĹÌļ125AĜÈ1ERdÌasdk@##'

--select * from (values(@input )) a
Declare @allowed_chars as varchar(50)
Set @allowed_chars = '%[^0-9A-Za-z]%'

declare @output NVARCHAR(MAX)  = @input
select  @output = IIF(CHARINDEX(special_char, @output) <> 0, REPLACE(@output, special_char , normal_char), @output)
from  #char_mapping

While PatIndex(@allowed_chars, @output) > 0
    Set @output = Stuff(@output, PatIndex(@allowed_chars, @output), 1, '')

select @output