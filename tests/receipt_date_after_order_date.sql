-- asegurar que la fecha de recepción del pedido nunca sea
-- anterior a la fecha de emisión del mismo.

{{ config(severity = 'warn') }}

WITH fact_orders AS (
    SELECT ID_ORDER, DT_ORDER 
    FROM {{ ref('fact_orders') }}
),
fact_lineitem AS (
    SELECT FK_ORDER, DT_RECEIPT 
    FROM {{ ref('fact_lineitem') }}
)

SELECT
    li.FK_ORDER,
    o.DT_ORDER,
    li.DT_RECEIPT
FROM fact_lineitem li
JOIN fact_orders o ON li.FK_ORDER = o.ID_ORDER
WHERE li.DT_RECEIPT < o.DT_ORDER