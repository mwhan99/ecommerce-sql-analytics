-- Lesson 2: GROUP BY, aggregates and HAVING
-- Data: Olist Brazilian e-commerce (staging tables)

-- Exercise 1: How do customers pay?
-- Number of payments and total amount paid by payment type
SELECT payment_type,
       COUNT(*) AS payments,
       SUM(payment_value) AS total_paid
FROM staging.stg_payments
GROUP BY payment_type
ORDER BY total_paid DESC;

-- Exercise 2: What do reviews look like?
-- Number of reviews for each score, 1 to 5
SELECT review_score,
       COUNT(*) AS reviews
FROM staging.stg_reviews
GROUP BY review_score
ORDER BY review_score ASC;

-- Exercise 3: Are voucher payments smaller?
-- Average payment by payment type, rounded to 2 decimals
-- Finding: vouchers average R$65.70 vs R$163.32 for credit cards,
-- likely because vouchers often cover only part of an order
SELECT payment_type,
       COUNT(*) AS payments,
       ROUND(AVG(payment_value), 2) AS avg_value
FROM staging.stg_payments
GROUP BY payment_type
ORDER BY avg_value DESC;

-- Exercise 4: Which states have more than 5,000 customers?
-- COUNT(DISTINCT customer_unique_id) counts each person once,
-- because Olist gives a customer a new customer_id for every order
-- HAVING filters groups after GROUP BY (WHERE filters rows before)
SELECT state,
       COUNT(DISTINCT customer_unique_id) AS customers
FROM staging.stg_customers
GROUP BY state
HAVING COUNT(DISTINCT customer_unique_id) > 5000
ORDER BY customers DESC;