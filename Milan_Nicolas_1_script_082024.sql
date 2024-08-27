SELECT 
	* 
FROM 
	orders 
WHERE
	order_status !='canceled'
AND
	order_purchase_timestamp >= DATE('now', '-30 days') 
AND
	JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_estimated_delivery_date) >=3;

SELECT 
    s.seller_id, 
    SUM(oi.price) AS total_revenue
FROM 
    order_items oi
JOIN 
    sellers s ON oi.seller_id = s.seller_id
GROUP BY 
    s.seller_id
HAVING 
    total_revenue >100000;


WITH seller_first_sale AS (
    SELECT 
        s.seller_id,
        MIN(o.order_purchase_timestamp) AS first_sale_date
    FROM 
        sellers s
    JOIN 
        order_items oi ON s.seller_id = oi.seller_id
    JOIN 
        orders o ON oi.order_id = o.order_id
    GROUP BY 
        s.seller_id
),
new_sellers AS (
    SELECT 
        seller_id
    FROM 
        seller_first_sale
    WHERE 
        first_sale_date >= DATE('now', '-90 days')
),
seller_sales AS (
    SELECT 
        oi.seller_id, 
        COUNT(oi.order_item_id) AS products_sold
    FROM 
        order_items oi
    GROUP BY 
        oi.seller_id
)
SELECT 
    ns.seller_id, 
    ss.products_sold
FROM 
    new_sellers ns
JOIN 
    seller_sales ss ON ns.seller_id = ss.seller_id
WHERE 
    ss.products_sold > 30;


WITH recent_reviews AS (
    SELECT 
        r.review_id,
        r.review_score,
        c.customer_zip_code_prefix,
        r.review_creation_date
    FROM 
        order_reviews r
    JOIN 
        orders o ON r.order_id = o.order_id
    JOIN 
        customers c ON o.customer_id = c.customer_id
    WHERE 
        r.review_creation_date >= DATE('now', '-12 months')
),
zipcode_review_stats AS (
    SELECT 
        rr.customer_zip_code_prefix,
        COUNT(rr.review_id) AS review_count,
        AVG(rr.review_score) AS avg_review_score
    FROM 
        recent_reviews rr
    GROUP BY 
        rr.customer_zip_code_prefix
    HAVING 
        review_count > 30
)
SELECT 
    customer_zip_code_prefix,
    review_count,
    avg_review_score
FROM 
    zipcode_review_stats
ORDER BY 
    avg_review_score ASC
LIMIT 5;







