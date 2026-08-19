{{
    config(
        materialized='table',
        alias='DIM_SUPPLIER'
    )
}}

WITH clean_supplier AS (
    SELECT
        s_suppkey                   AS ID_SUPPLIER,
        s_nationkey                 AS FK_NATION,
        UPPER(TRIM(s_name))         AS AT_SUPPLIER_NAME,
        UPPER(TRIM(s_address))      AS AT_ADDRESS,
        UPPER(TRIM(s_phone))        AS AT_PHONE,
        UPPER(TRIM(s_comment))      AS AT_COMMENT,
        s_acctbal                   AS MT_ACCOUNT_BALANCE
    FROM {{ ref('raw_supplier') }}
)

SELECT
    ID_SUPPLIER,
    FK_NATION,
    AT_SUPPLIER_NAME,
    AT_ADDRESS,
    AT_PHONE,
    AT_COMMENT,
    
    -- clasificación del proveedor según balance
    CASE 
        WHEN MT_ACCOUNT_BALANCE < 0 THEN 'DEBT'
        WHEN MT_ACCOUNT_BALANCE BETWEEN 0 AND 5000 THEN 'STANDARD'
        ELSE 'PREMIUM'
    END AS AT_SUPPLIER_TIER,
    
    -- flag proveedores con balance alto
    CASE 
        WHEN MT_ACCOUNT_BALANCE > 5000 THEN TRUE 
        ELSE FALSE 
    END AS IS_HIGH_BALANCE_SUPPLIER,
    
    MT_ACCOUNT_BALANCE,

    CURRENT_TIMESTAMP() AS AUDITTS_CREATION,
    CURRENT_TIMESTAMP() AS AUDITTS_MODIFICATION
FROM clean_supplier