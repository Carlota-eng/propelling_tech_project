{{
    config(
        materialized='incremental',
        unique_key=['l_orderkey', 'l_linenumber'],
        strategy='merge'
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
    CURRENT_TIMESTAMP() AS RAW_LODADED_AT
FROM {{ source('tpch_source', 'lineitem') }}

{% if is_incremental() %
    WHERE l_orderkey >= (SELECT COALESCE(MAX(l_orderkey), 0) FROM {{ this }})
{% endif %}