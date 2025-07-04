 
USE [STAGE_STUDY];
GO

-- Cria o schema STAGE_STUDY, se ainda não existir
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'STAGE_STUDY')
BEGIN
    EXEC('CREATE SCHEMA STAGE_STUDY AUTHORIZATION dbo');
    PRINT 'Schema STAGE_STUDY criado.';
END
ELSE
BEGIN
    PRINT 'Schema STAGE_STUDY já existe.';
END
GO

-- 1) Se a procedure já existir, remove
IF OBJECT_ID('STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE;
    PRINT 'Procedure STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE removida.';
END
GO

-- 2) Cria a procedure 
CREATE PROCEDURE STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('STAGE_STUDY.FT_PESQUISA_SITE', 'U') IS NULL
    BEGIN
        CREATE TABLE STAGE_STUDY.FT_PESQUISA_SITE
        (
            ID              INT           NOT NULL PRIMARY KEY,
            DS_PRODUTO      NVARCHAR(4000) NOT NULL,
            PRECO           DECIMAL(18,2)  NOT NULL,
            CATEGORIA       VARCHAR(20)    NOT NULL,
            FABRICANTE      VARCHAR(50)    NOT NULL,
            DATA_REFERENCIA DATETIME       NOT NULL
        );
        PRINT 'Tabela STAGE_STUDY.FT_PESQUISA_SITE criada.';
    END;

    WITH CTE_Novos AS
    (
        SELECT
            t.ID,
            t.MARCA            AS DS_PRODUTO,
            t.PRECO,
            CASE
                WHEN UPPER(t.MARCA) LIKE '%MOUSE%' AND UPPER(t.MARCA) NOT LIKE '%TECLADO%' THEN 'MOUSE'
                WHEN (UPPER(t.MARCA) LIKE '%TECLADO%' OR UPPER(t.MARCA) LIKE '%KEYBOARD%') AND UPPER(t.MARCA) NOT LIKE '%MOUSE%' THEN 'TECLADO'
                WHEN UPPER(t.MARCA) LIKE '%MOUSE%' AND UPPER(t.MARCA) LIKE '%TECLADO%' THEN 'KIT COMPLETO'
                ELSE 'OUTROS'
            END AS CATEGORIA,
            CASE 
                WHEN UPPER(t.MARCA) LIKE '%5+%' THEN '5+'
                WHEN UPPER(t.MARCA) LIKE '%ACER%' THEN 'ACER'
                WHEN UPPER(t.MARCA) LIKE '%AKKO%' THEN 'AKKO'
                WHEN UPPER(t.MARCA) LIKE '%ALLAY PRODUCTION%' THEN 'ALLAY PRODUCTION'
                WHEN UPPER(t.MARCA) LIKE '%ALTOMEX%' THEN 'ALTOMEX'
                WHEN UPPER(t.MARCA) LIKE '%AOC%' THEN 'AOC'
                WHEN UPPER(t.MARCA) LIKE '%APLUS TECH%' THEN 'APLUS TECH'
                WHEN UPPER(t.MARCA) LIKE '%APPLE%' THEN 'APPLE'
                WHEN UPPER(t.MARCA) LIKE '%B MAX%' THEN 'B-MAX'
                WHEN UPPER(t.MARCA) LIKE '%B-MAX%' THEN 'B-MAX'
                WHEN UPPER(t.MARCA) LIKE '%BLUECASE%' THEN 'BLUECASE'
                WHEN UPPER(t.MARCA) LIKE '%BMAX%' THEN 'BMAX'
                WHEN UPPER(t.MARCA) LIKE '%BPC%' THEN 'BPC'
                WHEN UPPER(t.MARCA) LIKE '%BRAZIL PC%' THEN 'BRAZILPC'
                WHEN UPPER(t.MARCA) LIKE '%BRAZILPC%' THEN 'BRAZILPC'
                WHEN UPPER(t.MARCA) LIKE '%BRIGHT%' THEN 'BRIGHT'
                WHEN UPPER(t.MARCA) LIKE '%BRX%' THEN 'BRX'
                WHEN UPPER(t.MARCA) LIKE '%C3 TECHTECH%' THEN 'C3'
                WHEN UPPER(t.MARCA) LIKE '%C3PLUS%' THEN 'C3'
                WHEN UPPER(t.MARCA) LIKE '%C3TECH%' THEN 'C3'
                WHEN UPPER(t.MARCA) LIKE '%C3TECH | MAXPRINT%' THEN 'C3'
                WHEN UPPER(t.MARCA) LIKE '%C3TECHTECH%' THEN 'C3'
                WHEN UPPER(t.MARCA) LIKE '%CHINAMATE%' THEN 'CHINAMATE'
                WHEN UPPER(t.MARCA) LIKE '%CHIP SCE%' THEN 'CHIP SCE'
                WHEN UPPER(t.MARCA) LIKE '%CLANM%' THEN 'CLANM'
                WHEN UPPER(t.MARCA) LIKE '%CONCORDIA%' THEN 'CONCORDIA'
                WHEN UPPER(t.MARCA) LIKE '%COOLER MASTER%' THEN 'COOLER MASTER'
                WHEN UPPER(t.MARCA) LIKE '%DAZZ%' THEN 'DAZZ'
                WHEN UPPER(t.MARCA) LIKE '%DEKO%' THEN 'DEKO'
                WHEN UPPER(t.MARCA) LIKE '%DELL%' THEN 'DELL'
                WHEN UPPER(t.MARCA) LIKE '%DEX%' THEN 'DEX'
                WHEN UPPER(t.MARCA) LIKE '%DIGITADOR%' THEN 'DIGITADOR'
                WHEN UPPER(t.MARCA) LIKE '%EBAI%' THEN 'EBAI'
                WHEN UPPER(t.MARCA) LIKE '%EVOLUT%' THEN 'EVOLUT'
                WHEN UPPER(t.MARCA) LIKE '%EVUS%' THEN 'EVUS'
                WHEN UPPER(t.MARCA) LIKE '%EXBOM%' THEN 'EXBOM'
                WHEN UPPER(t.MARCA) LIKE '%F3%' THEN 'F3'
                WHEN UPPER(t.MARCA) LIKE '%FAM%' THEN 'FAM'
                WHEN UPPER(t.MARCA) LIKE '%FORCE ONE%' THEN 'FORCE ONE'
                WHEN UPPER(t.MARCA) LIKE '%FORTREK%' THEN 'FORTREK'
                WHEN UPPER(t.MARCA) LIKE '%FY%' THEN 'FY'
                WHEN UPPER(t.MARCA) LIKE '%GAMDIAS%' THEN 'GAMDIAS'
                WHEN UPPER(t.MARCA) LIKE '%GENERICO%' THEN 'GENERICO'
                WHEN UPPER(t.MARCA) LIKE '%GENIUS%' THEN 'GENIUS'
                WHEN UPPER(t.MARCA) LIKE '%GEONAV%' THEN 'GEONAV'
                WHEN UPPER(t.MARCA) LIKE '%GIGABYTE%' THEN 'GIGABYTE'
                WHEN UPPER(t.MARCA) LIKE '%GOLDENTEC%' THEN 'GOLDENTEC'
                WHEN UPPER(t.MARCA) LIKE '%GOLDENTEC ACESSORIOS%' THEN 'GOLDENTEC ACESSORIOS'
                WHEN UPPER(t.MARCA) LIKE '%GORILA SHIELD%' THEN 'GORILA SHIELD'
                WHEN UPPER(t.MARCA) LIKE '%H-MASTON%' THEN 'H-MASTON'
                WHEN UPPER(t.MARCA) LIKE '%H''MASTON%' THEN 'H''MASTON'
                WHEN UPPER(t.MARCA) LIKE '%HAYOM%' THEN 'HAYOM'
                WHEN UPPER(t.MARCA) LIKE '%HAYON%' THEN 'HAYOM'
                WHEN UPPER(t.MARCA) LIKE '%HIKVISION%' THEN 'HIKVISION'
                WHEN UPPER(t.MARCA) LIKE '%HITTO%' THEN 'HITTO'
                WHEN UPPER(t.MARCA) LIKE '%HOLY DRAGON%' THEN 'HOLY DRAGON'
                WHEN UPPER(t.MARCA) LIKE '%HOOPSON%' THEN 'HOOPSON'
                WHEN UPPER(t.MARCA) LIKE '%HP%' THEN 'HP'
                WHEN UPPER(t.MARCA) LIKE '%HREBOS%' THEN 'HREBOS'
                WHEN UPPER(t.MARCA) LIKE '%HYPERX%' THEN 'HYPERX'
                WHEN UPPER(t.MARCA) LIKE '%IBOX%' THEN 'IBOX'
                WHEN UPPER(t.MARCA) LIKE '%INFOWISE%' THEN 'INFOWISE'
                WHEN UPPER(t.MARCA) LIKE '%INOVA%' THEN 'INOVA'
                WHEN UPPER(t.MARCA) LIKE '%INSIGNIA%' THEN 'INSIGNIA'
                WHEN UPPER(t.MARCA) LIKE '%INTELBRAS%' THEN 'INTELBRAS'
                WHEN UPPER(t.MARCA) LIKE '%JETWAY%' THEN 'JETWAY'
                WHEN UPPER(t.MARCA) LIKE '%K-MEX%' THEN 'K-MEX'
                WHEN UPPER(t.MARCA) LIKE '%KAPBOM%' THEN 'KAPBOM'
                WHEN UPPER(t.MARCA) LIKE '%KEYTIME%' THEN 'KEYTIME'
                WHEN UPPER(t.MARCA) LIKE '%KMEX%' THEN 'KMEX'
                WHEN UPPER(t.MARCA) LIKE '%KNUP%' THEN 'KNUP'
                WHEN UPPER(t.MARCA) LIKE '%KOSS%' THEN 'KOSS'
                WHEN UPPER(t.MARCA) LIKE '%KP%' THEN 'KP'
                WHEN UPPER(t.MARCA) LIKE '%KROSS%' THEN 'KROSS'
                WHEN UPPER(t.MARCA) LIKE '%KROSS ELEGANCE%' THEN 'KROSS'
                WHEN UPPER(t.MARCA) LIKE '%KTROK%' THEN 'KTROK'
                WHEN UPPER(t.MARCA) LIKE '%LECOO%' THEN 'LECOO'
                WHEN UPPER(t.MARCA) LIKE '%LEHMOX%' THEN 'LEHMOX'
                WHEN UPPER(t.MARCA) LIKE '%LENOVO%' THEN 'LENOVO'
                WHEN UPPER(t.MARCA) LIKE '%LG%' THEN 'LG'
                WHEN UPPER(t.MARCA) LIKE '%LOGITECH G%' THEN 'LOGITECH G'
                WHEN UPPER(t.MARCA) LIKE '%LOGITECH%' THEN 'LOGITECH'
                WHEN UPPER(t.MARCA) LIKE '%LOTUS%' THEN 'LOTUS'
                WHEN UPPER(t.MARCA) LIKE '%MAKETECH%' THEN 'MAKETECH'
                WHEN UPPER(t.MARCA) LIKE '%MAX PRINT%' THEN 'MAXPRINT'
                WHEN UPPER(t.MARCA) LIKE '%MAX%PRINT%' THEN 'MAXPRINT'
                WHEN UPPER(t.MARCA) LIKE '%MAXPRINT%' THEN 'MAXPRINT'
                WHEN UPPER(t.MARCA) LIKE '%MBFIT%' THEN 'MBFIT'
                WHEN UPPER(t.MARCA) LIKE '%MBTECH%' THEN 'MBTECH'
                WHEN UPPER(t.MARCA) LIKE '%MICRODIGI%' THEN 'MICRODIGI'
                WHEN UPPER(t.MARCA) LIKE '%MICROSOFT%' THEN 'MICROSOFT'
                WHEN UPPER(t.MARCA) LIKE '%MINI%' THEN 'MINI'
                WHEN UPPER(t.MARCA) LIKE '%MONOCRON%' THEN 'MONOCRON'
                WHEN UPPER(t.MARCA) LIKE '%MONSGEEK%' THEN 'MONSGEEK'
                WHEN UPPER(t.MARCA) LIKE '%MOX%' THEN 'MOX'
                WHEN UPPER(t.MARCA) LIKE '%MULTI%' THEN 'MULTI'
                WHEN UPPER(t.MARCA) LIKE '%MULTIVISÃO%' THEN 'MULTIVISÃO'
                WHEN UPPER(t.MARCA) LIKE '%MX3%' THEN 'MX3'
                WHEN UPPER(t.MARCA) LIKE '%MYMAX%' THEN 'MYMAX'
                WHEN UPPER(t.MARCA) LIKE '%NAVE%' THEN 'NAVE'
                WHEN UPPER(t.MARCA) LIKE '%NEW LINK%' THEN 'NEWLINK'
                WHEN UPPER(t.MARCA) LIKE '%NEWLINK%' THEN 'NEWLINK'
                WHEN UPPER(t.MARCA) LIKE '%NT%' THEN 'NT'
                WHEN UPPER(t.MARCA) LIKE '%NTC%' THEN 'NTC'
                WHEN UPPER(t.MARCA) LIKE '%OEM%' THEN 'OEM'
                WHEN UPPER(t.MARCA) LIKE '%OEX GAME%' THEN 'OEX'
                WHEN UPPER(t.MARCA) LIKE '%OEX%' THEN 'OEX'
                WHEN UPPER(t.MARCA) LIKE '%OUTROS%' THEN 'OUTROS'
                WHEN UPPER(t.MARCA) LIKE '%PCFORT%' THEN 'PCFORT'
                WHEN UPPER(t.MARCA) LIKE '%PCYES%' THEN 'PCYES'
                WHEN UPPER(t.MARCA) LIKE '%PEINING%' THEN 'PEINING'
                WHEN UPPER(t.MARCA) LIKE '%PHILIPS%' THEN 'PHILIPS'
                WHEN UPPER(t.MARCA) LIKE '%PIXXO%' THEN 'PIXXO'
                WHEN UPPER(t.MARCA) LIKE '%PONTO DO NERD%' THEN 'PONTO DO NERD'
                WHEN UPPER(t.MARCA) LIKE '%POTENCIAL%' THEN 'POTENCIAL'
                WHEN UPPER(t.MARCA) LIKE '%RAPOO%' THEN 'RAPOO'
                WHEN UPPER(t.MARCA) LIKE '%RAZER%' THEN 'RAZER'
                WHEN UPPER(t.MARCA) LIKE '%REDRAGON%' THEN 'REDRAGON'
                WHEN UPPER(t.MARCA) LIKE '%RELIZA%' THEN 'RELIZA'
                WHEN UPPER(t.MARCA) LIKE '%RISE MODE%' THEN 'RISE MODE'
                WHEN UPPER(t.MARCA) LIKE '%SATECHI%' THEN 'SATECHI'
                WHEN UPPER(t.MARCA) LIKE '%SATELLITE%' THEN 'SATELLITE'
                WHEN UPPER(t.MARCA) LIKE '%SMART%' THEN 'SMART'
                WHEN UPPER(t.MARCA) LIKE '%STEELSERIES%' THEN 'STEELSERIES'
                WHEN UPPER(t.MARCA) LIKE '%STORM-Z%' THEN 'STORM-Z'
                WHEN UPPER(t.MARCA) LIKE '%TANCA%' THEN 'TANCA'
                WHEN UPPER(t.MARCA) LIKE '%TARGUS%' THEN 'TARGUS'
                WHEN UPPER(t.MARCA) LIKE '%THERMALTAKE%' THEN 'THERMALTAKE'
                WHEN UPPER(t.MARCA) LIKE '%TIGER%' THEN 'TIGER'
                WHEN UPPER(t.MARCA) LIKE '%TOMATE%' THEN 'TOMATE'
                WHEN UPPER(t.MARCA) LIKE '%TRUST%' THEN 'TRUST'
                WHEN UPPER(t.MARCA) LIKE '%TWS%' THEN 'TWS'
                WHEN UPPER(t.MARCA) LIKE '%UGREEN%' THEN 'UGREEN'
                WHEN UPPER(t.MARCA) LIKE '%UNIVERSAL%' THEN 'UNIVERSAL'
                WHEN UPPER(t.MARCA) LIKE '%VINIK%' THEN 'VINIK'
                WHEN UPPER(t.MARCA) LIKE '%VX PRO%' THEN 'VX PRO'
                WHEN UPPER(t.MARCA) LIKE '%VXPRO%' THEN 'VXPRO'
                WHEN UPPER(t.MARCA) LIKE '%WD%' THEN 'WD'
                WHEN UPPER(t.MARCA) LIKE '%X-CELL%' THEN 'X-CELL'
                WHEN UPPER(t.MARCA) LIKE '%XIAOMI%' THEN 'XIAOMI'
                WHEN UPPER(t.MARCA) LIKE '%XLINNE%' THEN 'XLINNE'
                WHEN UPPER(t.MARCA) LIKE '%XTRAD%' THEN 'XTRAD'
                ELSE 'OUTROS'
            END AS FABRICANTE
        FROM STAGE_STUDY.dbo.[ST_MARCA_PRECO_KBM] t -- Mantém a referência à tabela no schema dbo
    )
    INSERT INTO STAGE_STUDY.FT_PESQUISA_SITE (ID, DS_PRODUTO, PRECO, CATEGORIA, FABRICANTE, DATA_REFERENCIA)
    SELECT
        n.ID,
        n.DS_PRODUTO,
        n.PRECO,
        n.CATEGORIA,
        n.FABRICANTE,
        GETDATE()
    FROM CTE_Novos AS n
    LEFT JOIN STAGE_STUDY.FT_PESQUISA_SITE AS f ON n.ID = f.ID
    WHERE
        n.CATEGORIA <> 'OUTROS'
        AND f.ID IS NULL;

    DECLARE @RowCount INT = @@ROWCOUNT;
    IF @RowCount > 0
        PRINT CONVERT(VARCHAR(10), @RowCount) + ' novos registros inseridos em STAGE_STUDY.FT_PESQUISA_SITE.';

END;
GO

PRINT 'Procedure STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE criada ou atualizada.';
GO

-- Se o trigger já existir NO SCHEMA. remove
IF OBJECT_ID('dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT', 'TR') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT;
    PRINT 'Trigger dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT removido.';
END
GO

--  Cria o Trigger para executar a procedure 
CREATE TRIGGER dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT
ON STAGE_STUDY.dbo.[ST_MARCA_PRECO_KBM] -- Tabela alvo continua sendo dbo.ST_MARCA_PRECO_KBM
AFTER INSERT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    SET NOCOUNT ON;

    PRINT 'Trigger dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT disparado. Executando usp_Populate_FT_PESQUISA_SITE...';

    -- Executa a procedure que está no schema STAGE_STUDY 
    EXEC STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE;

    PRINT 'Execução de STAGE_STUDY.usp_Populate_FT_PESQUISA_SITE concluída pelo trigger.';

END;
GO


PRINT 'Trigger dbo.TRG_ST_MARCA_PRECO_KBM_Populate_FT criado.';
GO

