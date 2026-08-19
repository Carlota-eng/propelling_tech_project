{{
    config(
        materialized='view',
        alias='CUST_SUPPLIER_LOGISTICS'
    )
}}

SELECT
    S.ID_SUPPLIER,
    S.AT_SUPPLIER_NAME,
    S.AT_SUPPLIER_TIER,
    N.AT_NATION_NAME,
    R.AT_REGION_NAME,
    COUNT(L.FK_ORDER)                                       AS MT_TOTAL_ITEMS_SUPPLIED,
    SUM(CASE WHEN L.IS_DELAYED_DELIVERY THEN 1 ELSE 0 END)  AS MT_DELAYED_ITEMS_COUNT,
    ROUND(AVG(L.CA_NET_PRICE), 2)                           AS MT_AVG_SUPPLY_AMOUNT
FROM {{ ref('dim_supplier') }} AS S
JOIN {{ ref('lkp_nation') }} AS N ON S.FK_NATION = N.ID_NATION
JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION
LEFT JOIN {{ ref('fact_lineitem') }} AS L ON S.ID_SUPPLIER = L.FK_SUPPLIER
GROUP BY 1, 2, 3, 4, 5