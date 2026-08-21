{{
    config(
        materialized='view',
        alias='CUST_SALES_PERFORMANCE'
    )
}}

SELECT
    EXTRACT(YEAR FROM O.DT_ORDER)          AS DT_YEAR,
    EXTRACT(MONTH FROM O.DT_ORDER)         AS DT_MONTH,
    R.AT_REGION_NAME,
    N.AT_NATION_NAME,
    C.AT_MARKET_SEGMENT,
    O.AT_ORDER_SIZE_CATEGORY,              
    O.IS_URGENT_ORDER,                     
    COUNT(DISTINCT O.ID_ORDER)             AS MT_TOTAL_ORDERS,
    SUM(O.MT_TOTAL_PRICE)                  AS MT_TOTAL_NET_SALES,
    AVG(O.MT_TOTAL_PRICE)                  AS MT_AVG_ORDER_VALUE
FROM {{ ref('fact_orders') }} AS O
JOIN {{ ref('dim_customer') }} AS C ON O.FK_CUSTOMER = C.ID_CUSTOMER
JOIN {{ ref('lkp_nation') }} AS N ON C.FK_NATION = N.ID_NATION
JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION
GROUP BY 1, 2, 3, 4, 5, 6, 7