{{
    config(
        materialized='incremental',
        unique_key=['FK_PART', 'FK_SUPPLIER'],
        incremental_strategy='merge',
        alias='LKP_PARTSUPP'
    )
}}

WITH clean_partsupp AS (
    SELECT
        ps_partkey                  AS FK_PART,
        ps_suppkey                  AS FK_SUPPLIER,
        ps_availqty                 AS MT_AVAILABLE_QTY,
        ps_supplycost               AS MT_SUPPLY_COST,
        UPPER(TRIM(ps_comment))     AS AT_COMMENT,
        RAW_LOADED_AT               AS DT_RAW_LOADED_AT
    FROM {{ ref('raw_partsupp') }}
),

transformed_partsupp AS (
    SELECT
        FK_PART,
        FK_SUPPLIER,
        MT_AVAILABLE_QTY,
        MT_SUPPLY_COST,
        AT_COMMENT,
        
        -- audits
        DT_RAW_LOADED_AT AS AUDITTS_CREATION,
        CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
    FROM clean_partsupp
)

SELECT * FROM transformed_partsupp

-- filtro incremental estándar por ID máximo
{{ incremental_filter('FK_PART') }}