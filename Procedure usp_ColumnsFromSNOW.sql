USE [rds]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Rafael Ribeiro | Linkedin:  https://www.linkedin.com/in/rfelribeiro/
-- Create date: 11/09/2023
-- Description:	Busca colunas do ServiceNow passando o nome da tabela como parâmetro.
-- =============================================
CREATE OR ALTER  PROCEDURE [dbo].[usp_ColumnsFromSNOW] 
	(
		@table varchar(50)
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @query varchar(256);
	set @query = 'select * from oa_columns where table_name = '''''+@table+''''''

	IF OBJECT_ID('tempdb..##oa_columns') IS NOT NULL
    DROP TABLE ##oa_columns

	execute ('SELECT * INTO ##OA_COLUMNS FROM OPENQUERY(SERVICENOW, '''+ @query + ''')')

	print('Tabela ##oa_columns criada!')

END
GO

