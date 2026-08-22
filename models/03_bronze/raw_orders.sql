{{
    config(
        materialized='incremental',
        unique_key='o_orderkey',
        incremental_strategy='merge'
    )
}}

SELECT 
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate,
    o_orderpriority,
    o_clerk,
    o_shippriority,
    o_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'orders') }}

{{ incremental_filter('o_orderkey') }}

UNION ALL

-- Inyectamos un registro falso con precio negativo para que el test salte
SELECT 
    9999999 AS o_orderkey,
    1 AS o_custkey,
    'O' AS o_orderstatus,
    -150.00 AS o_totalprice,
    CURRENT_DATE() AS o_orderdate,
    '1-URGENT' AS o_orderpriority,
    'CLERK#000000001' AS o_clerk,
    0 AS o_shippriority,
    'Test negative price' AS o_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT