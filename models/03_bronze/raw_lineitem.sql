{{
    config(
        materialized='incremental',
        unique_key=['l_orderkey', 'l_linenumber'],
        incremental_strategy='merge'
    )
}}

SELECT 
    l_orderkey,
    l_partkey,
    l_suppkey,
    l_linenumber,
    l_quantity,
    l_extendedprice,
    l_discount,
    l_tax,
    l_returnflag,
    l_linestatus,
    l_shipdate,
    l_commitdate,
    l_receiptdate,
    l_shipinstruct,
    l_shipmode,
    l_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'lineitem') }}

{{ incremental_filter('l_orderkey') }}

UNION ALL

-- Inyectamos un registro falso con una fecha de recepción anterior a la fecha de envío/pedido
SELECT 
    8888888 AS l_orderkey,
    1 AS l_partkey,
    1 AS l_suppkey,
    1 AS l_linenumber,
    10 AS l_quantity,
    1000.00 AS l_extendedprice,
    0.0 AS l_discount,
    0.0 AS l_tax,
    'N' AS l_returnflag,
    'O' AS l_linestatus,
    '2026-01-15' AS l_shipdate,
    '2026-01-15' AS l_commitdate,
    '2025-01-01' AS l_receiptdate,
    'DELIVER' AS l_shipinstruct,
    'AIR' AS l_shipmode,
    'Test bad date for warning validation' AS l_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT