{{ config(materialized='table') }}

SELECT *
FROM {{ source('tpch_source', 'lineitem') }}