{{
    config(
        materialized='incremental',
        unique_key=['FK_ORDER', 'ID_LINE_NUMBER'],
        incremental_strategy='merge',
        alias='FACT_LINEITEM'
    )
}}

WITH clean_lineitem AS (
    SELECT
        l_orderkey                          AS FK_ORDER,
        l_partkey                           AS FK_PART,
        l_suppkey                           AS FK_SUPPLIER,
        l_linenumber                        AS ID_LINE_NUMBER,
        CAST(l_shipdate AS DATE)            AS DT_SHIP,
        CAST(l_commitdate AS DATE)          AS DT_COMMIT,
        CAST(l_receiptdate AS DATE)         AS DT_RECEIPT,
        UPPER(TRIM(l_returnflag))           AS AT_RETURN_FLAG,
        UPPER(TRIM(l_linestatus))           AS AT_LINE_STATUS,
        UPPER(TRIM(l_shipinstruct))         AS AT_SHIP_INSTRUCT,
        UPPER(TRIM(l_shipmode))             AS AT_SHIP_MODE,
        UPPER(TRIM(l_comment))              AS AT_COMMENT,
        l_quantity                          AS MT_QUANTITY,
        l_extendedprice                     AS MT_EXTENDED_PRICE,
        l_discount                          AS MT_DISCOUNT,
        l_tax                               AS MT_TAX,
        RAW_LOADED_AT                       AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_lineitem') }}
),

transformed_lineitem AS (
    SELECT
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

        -- Auditoría interna
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_lineitem
)

SELECT * FROM transformed_lineitem

{% if is_incremental() %}
    WHERE FK_ORDER >= (SELECT COALESCE(MAX(FK_ORDER), 0) FROM {{ this }})
{% endif %}