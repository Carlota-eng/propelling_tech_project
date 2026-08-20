{{
    config(
        materialized='incremental',
        unique_key=['ps_partkey', 'ps_suppkey'],
        strategy='merge'
    )
}}

SELECT 
    ps_partkey,
    ps_suppkey,
    ps_availqty,
    ps_supplycost,
    ps_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'partsupp') }}

{% if is_incremental() %}
    WHERE ps_partkey >= (SELECT COALESCE(MAX(ps_partkey), 0) FROM {{ this }})
{% endif %}