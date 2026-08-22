{{
    config(
        materialized='incremental',
        unique_key='c_custkey',
        incremental_strategy='merge'
    )
}}

SELECT 
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'customer') }}

{{ incremental_filter('c_custkey') }}