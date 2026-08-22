-- asegurar que ninguna métrica de precio (mt_total_price, ca_net_rpice)
-- sea negativa o cero.

{{ config(severity = 'warn') }}

SELECT
    ID_ORDER,
    MT_TOTAL_PRICE,
    'Total price is negative or zero' AS error_message
FROM {{ ref('fact_orders') }}
WHERE MT_TOTAL_PRICE <= 0

UNION ALL

SELECT
    FK_ORDER,
    CA_NET_PRICE,
    'Net price is negative or zero' AS error_message
FROM {{ ref('fact_lineitem') }}
WHERE CA_NET_PRICE <= 0