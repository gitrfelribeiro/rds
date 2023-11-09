USE rds

-- =============================================
-- Author:		Rafael Ribeiro | Linkedin:  https://www.linkedin.com/in/rfelribeiro/
-- Create date: 11/09/2023
-- Description:	Query para buscar estrutura da tabela do ServiceNow passando o nome da tabela como parâmetro.
-- =============================================


IF OBJECT_ID('tempdb..##oa_columns') IS NOT NULL
    DROP TABLE ##oa_columns

IF OBJECT_ID('tempdb..#etl') IS NOT NULL
    DROP TABLE #etl

--
--SELECT * INTO #oa_columns FROM oa_columns

DECLARE @table varchar(40);
SET @table = 'sys_user'
exec dbo.usp_ColumnsFromSNOW @table
;WITH TipoColunas
as (
	select COLUMN_NAME,[TYPE_NAME],[OA_LENGTH] from ##oa_columns --where COLUMN_NAME not like 'dv_%'
),
etl as
(
	select 
		COLUMN_NAME coluna,
		CASE [TYPE_NAME] 
			WHEN 'TIMESTAMP' THEN 'DATETIME'
			WHEN 'DATE' THEN 'DATETIME'
			WHEN 'DECIMAL' THEN 'NUMERIC'
			WHEN 'WLONGVARCHAR' THEN 'NVARCHAR'
			WHEN 'VARCHAR' THEN 'NVARCHAR'
			ELSE [TYPE_NAME] 
		END tipo,
		CASE [TYPE_NAME] 
			WHEN 'TIMESTAMP' THEN ''
			WHEN 'DATE' THEN ''
			WHEN 'DECIMAL' THEN '(38,2)'
			WHEN 'WLONGVARCHAR' THEN '(MAX)'
			WHEN 'VARCHAR' THEN CONCAT('(',[OA_LENGTH],')')
			WHEN 'BIT' THEN ''
			WHEN 'INTEGER' THEN ''
			ELSE ''
		END tamanho,
		CASE COLUMN_NAME WHEN 'sys_id' then ' NOT NULL' else ' NULL'END obs
		

	from TipoColunas
)
select *
,script  =	'ALTER TABLE '+@table+' ADD '+QUOTENAME(coluna)+' '+tipo+' '+tamanho+obs 
,script2 =	'ALTER TABLE '+@table+' ALTER COLUMN '+QUOTENAME(coluna)+' '+tipo+' '+tamanho+obs
into #etl from etl;

update #etl set tamanho = '(1)' where tamanho = '(0)';

DECLARE @SQL NVARCHAR(MAX);
SET @SQL = '';

SELECT 
--@SQL,
@SQL = @SQL+','+QUOTENAME([coluna])+' '+[tipo]+[tamanho]+[obs]+'
'
FROM #etl;

SET @SQL = 'CREATE TABLE [dbo].'+QUOTENAME(@table)+' (' + RIGHT(@SQL,LEN(@SQL)-1) + '
)'

SET @SQL = @SQL + 'ALTER TABLE ' + @table +  ' ADD CONSTRAINT PK_'+@table+'_sys_id PRIMARY KEY CLUSTERED (sys_id);'

SELECT [SQL] = CAST(@SQL AS XML);


select * from #etl
--select * from  ##oa_columns;
