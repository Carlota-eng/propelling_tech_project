{{
    config(
        materialized='table',
        alias='LKP_REGION'
    )
}}

SELECT
    r_regionkey                 AS ID_REGION,
    UPPER(TRIM(r_name))         AS AT_REGION_NAME,
    UPPER(TRIM(r_comment))      AS AT_COMMENT,
    CURRENT_TIMESTAMP()         AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP()         AS AUDITTS_MODIFICATION
FROM {{ ref('raw_region') }}