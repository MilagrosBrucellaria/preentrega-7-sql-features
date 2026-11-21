-- ============================================================
-- PREENTREGA 7
-- Ingeniería de Features con SQL Analítico Avanzado
-- Features: Recency, Frequency, Monetary y Trend
-- ============================================================



WITH valid_transactions AS (

    -- 1. Limpiamos las transacciones
    SELECT
        CAST(CustomerID AS VARCHAR) AS customer_id,
        CAST(InvoiceNo AS VARCHAR) AS invoice_no,
        CAST(InvoiceDate AS TIMESTAMP) AS invoice_date,
        CAST(Quantity AS INTEGER) AS quantity,
        CAST(UnitPrice AS DOUBLE) AS unit_price,
        CAST(Quantity AS DOUBLE) * CAST(UnitPrice AS DOUBLE) AS amount

    FROM online_retail

    WHERE CustomerID IS NOT NULL
      AND Quantity > 0
      AND UnitPrice > 0
      AND UPPER(CAST(InvoiceNo AS VARCHAR)) NOT LIKE 'C%'
),

reference_date AS (

    -- 2. Definimos una fecha de referencia
    SELECT
        MAX(CAST(invoice_date AS DATE)) + INTERVAL 1 DAY AS analysis_date
    FROM valid_transactions
),

customer_rfm AS (

    -- 3. Calculamos Recency, Frequency y Monetary
    SELECT
        customer_id,

        DATE_DIFF(
            'day',
            MAX(CAST(invoice_date AS DATE)),
            (SELECT analysis_date FROM reference_date)
        ) AS recency_days,

        COUNT(DISTINCT invoice_no) AS frequency_orders,

        ROUND(SUM(amount), 2) AS monetary_total

    FROM valid_transactions

    GROUP BY customer_id
),

monthly_spending AS (

    -- 4. Calculamos cuánto gastó cada cliente por mes
    SELECT
        customer_id,
        DATE_TRUNC('month', invoice_date) AS purchase_month,
        SUM(amount) AS monthly_amount

    FROM valid_transactions

    GROUP BY
        customer_id,
        DATE_TRUNC('month', invoice_date)
),

monthly_features AS (

    -- 5. Aplicamos funciones de ventana
    SELECT
        customer_id,
        purchase_month,
        monthly_amount,

        -- Ventana 1: identifica el último mes
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month DESC
        ) AS month_position,

        -- Ventana 2: promedio histórico
        AVG(monthly_amount) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS historical_monthly_average,

        -- Ventana 3: gasto acumulado
        SUM(monthly_amount) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS accumulated_spending

    FROM monthly_spending
),

latest_month AS (

    -- 6. Nos quedamos con el último mes de cada cliente
    SELECT
        customer_id,
        monthly_amount AS last_month_spending,

        COALESCE(
            historical_monthly_average,
            0
        ) AS historical_monthly_average,

        accumulated_spending

    FROM monthly_features

    WHERE month_position = 1
)

-- 7. Construimos el dataset final
SELECT
    rfm.customer_id,

    COALESCE(rfm.recency_days, 0) AS recency_days,

    COALESCE(rfm.frequency_orders, 0) AS frequency_orders,

    COALESCE(rfm.monetary_total, 0) AS monetary_total,

    ROUND(
        COALESCE(lm.last_month_spending, 0),
        2
    ) AS last_month_spending,

    ROUND(
        COALESCE(lm.historical_monthly_average, 0),
        2
    ) AS historical_monthly_average,

    ROUND(
        COALESCE(lm.last_month_spending, 0)
        - COALESCE(lm.historical_monthly_average, 0),
        2
    ) AS spending_trend,

    ROUND(
        COALESCE(lm.accumulated_spending, 0),
        2
    ) AS accumulated_spending

FROM customer_rfm AS rfm

LEFT JOIN latest_month AS lm
    ON rfm.customer_id = lm.customer_id

ORDER BY rfm.customer_id

