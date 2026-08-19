{{
    config(
        materialized='table',
        alias='FACT_ORDERS'
    )
}}

WITH clean_orders AS (
    SELECT
        o_orderkey                      AS ID_ORDER,
        o_custkey                       AS FK_CUSTOMER,
        UPPER(TRIM(o_orderstatus))      AS AT_ORDER_STATUS,
        o_orderdate                     AS DT_ORDER,
        UPPER(TRIM(o_orderpriority))    AS AT_ORDER_PRIORITY,
        UPPER(TRIM(o_clerk))            AS AT_CLERK,
        o_shippriority                  AS AT_SHIP_PRIORITY,
        UPPER(TRIM(o_comment))          AS AT_COMMENT,
        o_totalprice                    AS MT_TOTAL_PRICE
    FROM {{ ref('raw_orders') }}
)

SELECT
    -- ids y fks
    ID_ORDER,
    FK_CUSTOMER,
    
    -- atributos
    AT_ORDER_STATUS,
    AT_ORDER_PRIORITY,
    AT_CLERK,
    AT_SHIP_PRIORITY,
    AT_COMMENT,
    
    -- clasificación order según valor
    CASE 
        WHEN MT_TOTAL_PRICE >= 150000 THEN 'HIGH_VALUE_ORDER'
        WHEN MT_TOTAL_PRICE BETWEEN 50000 AND 149999 THEN 'MEDIUM_VALUE_ORDER'
        ELSE 'LOW_VALUE_ORDER'
    END AS AT_ORDER_SIZE_CATEGORY,
    
    -- fechas
    DT_ORDER,
    
    -- flags si la orden es urgente
    CASE 
        WHEN AT_ORDER_PRIORITY LIKE '%URGENT%' THEN TRUE 
        ELSE FALSE 
    END AS IS_URGENT_ORDER,
    
    -- métricas
    MT_TOTAL_PRICE,

    -- audits
    CURRENT_TIMESTAMP() AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
FROM clean_orders