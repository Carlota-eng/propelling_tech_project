{{
    config(
        materialized='incremental',
        unique_key='ID_ORDER',
        strategy='merge',
        alias='FACT_ORDERS',
        update_columns=[
            'FK_CUSTOMER',
            'AT_ORDER_STATUS',
            'AT_ORDER_PRIORITY',
            'AT_CLERK',
            'AT_SHIP_PRIORITY',
            'AT_COMMENT',
            'AT_ORDER_SIZE_CATEGORY',
            'DT_ORDER',
            'IS_URGENT_ORDER',
            'MT_TOTAL_PRICE',
            'AUDITTS_MODIFICATION'
        ]
    )
}}

WITH clean_orders AS (
    SELECT
        o_orderkey                          AS ID_ORDER,
        o_custkey                           AS FK_CUSTOMER,
        UPPER(TRIM(o_orderstatus))          AS AT_ORDER_STATUS,
        CAST(o_orderdate AS DATE)           AS DT_ORDER,
        UPPER(TRIM(o_orderpriority))        AS AT_ORDER_PRIORITY,
        UPPER(TRIM(o_clerk))                AS AT_CLERK,
        o_shippriority                      AS AT_SHIP_PRIORITY,
        UPPER(TRIM(o_comment))              AS AT_COMMENT,
        o_totalprice                        AS MT_TOTAL_PRICE,
        RAW_LOADED_AT                       AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_orders') }}
),

transformed_orders AS (
    SELECT
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
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_orders
)

SELECT * FROM transformed_orders

{% if is_incremental() %}
    WHERE ID_ORDER > (SELECT COALESCE(MAX(ID_ORDER), 0) FROM {{ this }})
{% endif %}