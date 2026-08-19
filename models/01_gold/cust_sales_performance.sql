{{
    config(
        materialized='view',
        alias='CUST_SALES_PERFORMANCE'
    )
}}

WITH monthly_orders AS (
    SELECT
        O.ID_ORDER,
        O.DT_ORDER,
        O.FK_CUSTOMER,
        O.MT_TOTAL_PRICE
    FROM {{ ref('fact_orders') }} AS O
)

SELECT
    EXTRACT(YEAR FROM mo.DT_ORDER)      AS DT_YEAR,
    EXTRACT(MONTH FROM mo.DT_ORDER)     AS DT_MONTH,
    R.AT_REGION_NAME,
    N.AT_NATION_NAME,
    C.AT_MARKET_SEGMENT,
    COUNT(DISTINCT mo.ID_ORDER)         AS MT_TOTAL_ORDERS,
    SUM(mo.MT_TOTAL_PRICE)              AS MT_TOTAL_NET_SALES,
    ROUND(AVG(mo.MT_TOTAL_PRICE), 2)    AS MT_AVG_ORDER_VALUE
FROM monthly_orders AS mo
JOIN {{ ref('dim_customer') }} AS C ON mo.FK_CUSTOMER = C.ID_CUSTOMER
JOIN {{ ref('lkp_nation') }} AS N ON C.FK_NATION = N.ID_NATION
JOIN {{ ref('lkp_region') }} AS R ON N.FK_REGION = R.ID_REGION
GROUP BY 1, 2, 3, 4, 5
ORDER BY DT_MONTH DESC, MT_TOTAL_NET_SALES DESC