{{
    config(
        materialized='incremental',
        unique_key=['ps_partkey', 'ps_suppkey'],
        incremental_strategy='merge'
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

{{ incremental_filter('ps_partkey') }}