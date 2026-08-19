{{
    config(
        materialized='table',
        alias='FACT_LINEITEM'
    )
}}

WITH clean_lineitem AS (
    SELECT
        l_orderkey                      AS FK_ORDER,
        l_partkey                       AS FK_PART,
        l_suppkey                       AS FK_SUPPLIER,
        l_linenumber                    AS ID_LINE_NUMBER,
        l_shipdate                      AS DT_SHIP,
        l_commitdate                    AS DT_COMMIT,
        l_receiptdate                   AS DT_RECEIPT,
        UPPER(TRIM(l_returnflag))       AS AT_RETURN_FLAG,
        UPPER(TRIM(l_linestatus))       AS AT_LINE_STATUS,
        UPPER(TRIM(l_shipinstruct))     AS AT_SHIP_INSTRUCT,
        UPPER(TRIM(l_shipmode))         AS AT_SHIP_MODE,
        UPPER(TRIM(l_comment))          AS AT_COMMENT,
        l_quantity                      AS MT_QUANTITY,
        l_extendedprice                 AS MT_EXTENDED_PRICE,
        l_discount                      AS MT_DISCOUNT,
        l_tax                           AS MT_TAX
    FROM {{ ref('raw_lineitem') }}
)

SELECT
    -- ids y fks
    ID_LINE_NUMBER,
    FK_ORDER,
    FK_PART,
    FK_SUPPLIER,
    
    -- atributos
    AT_RETURN_FLAG,
    AT_LINE_STATUS,
    AT_SHIP_INSTRUCT,
    AT_SHIP_MODE,
    AT_COMMENT,
    
    -- fechas
    DT_SHIP,
    DT_COMMIT,
    DT_RECEIPT,
    
    -- flag para entregas retrasadas
    CASE 
        WHEN DT_RECEIPT > DT_COMMIT THEN TRUE 
        ELSE FALSE 
    END AS IS_DELAYED_DELIVERY,
    
    -- métricas
    MT_QUANTITY,
    MT_EXTENDED_PRICE,
    MT_DISCOUNT,
    MT_TAX,
    ROUND(MT_EXTENDED_PRICE * (1 - MT_DISCOUNT), 2)                     AS CA_NET_PRICE,
    ROUND((MT_EXTENDED_PRICE * (1 - MT_DISCOUNT)) * (1 + MT_TAX), 2)    AS CA_TOTAL_PRICE_WITH_TAX,

    -- audits
    CURRENT_TIMESTAMP() AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
FROM clean_lineitem