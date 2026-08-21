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

{% if is_incremental() %}
    WHERE o_orderkey > (SELECT COALESCE(MAX(o_orderkey), 0) FROM {{ this }})
{% endif %}