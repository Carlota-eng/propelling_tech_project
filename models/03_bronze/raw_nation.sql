{{
    config(
        materialized='incremental',
        unique_key='n_nationkey',
        incremental_strategy='merge'
    )
}}

SELECT 
    n_nationkey,
    n_name,
    n_regionkey,
    n_comment,
    CURRENT_TIMESTAMP() AS RAW_LOADED_AT
FROM {{ source('tpch_source', 'nation') }}

{{ incremental_filter('n_nationkey') }}