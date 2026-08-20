{{
    config(
        materialized='incremental',
        unique_key=['ps_partkey', 'ps_suppkey']
    )
}}

SELECT 
    ps_partkey,
    ps_suppkey,
    ps_availqty,
    ps_supplycost,
    ps_comment,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('tpch_source', 'partsupp') }}

{% if is_incremental() %}
    WHERE ps_partkey > (SELECT COALESCE(MAX(ps_partkey), 0) FROM {{ this }})
{% endif %}