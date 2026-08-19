{{
    config(
        materialized='table',
        alias='LKP_PARTSUPP'
    )
}}

SELECT
    ps_partkey                   AS FK_PART,
    ps_suppkey                   AS FK_SUPPLIER,
    ps_availqty                 AS MT_AVAILABLE_QTY,
    ps_supplycost               AS MT_SUPPLY_COST,
    UPPER(TRIM(ps_comment))     AS AT_COMMENT,
    CURRENT_TIMESTAMP()         AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP()         AS AUDITTS_MODIFICATION
FROM {{ ref('raw_partsupp') }}