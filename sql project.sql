use walmart;
## task 1	 
SELECT 
Branch, MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
SUM(Total) AS Monthly_Sales
FROM walmart_dataset
GROUP BY Branch, MONTH(STR_TO_DATE(Date, '%d-%m-%Y'))
ORDER BY Branch, Month;

WITH monthly_sales AS (
    SELECT 
        Branch,
        MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
        SUM(Total) AS Sales
    FROM walmart_dataset
    GROUP BY Branch, MONTH(STR_TO_DATE(Date, '%d-%m-%Y'))
),
growth_rate_calc AS (
    SELECT 
        Branch,
        Month,
        Sales,
        LAG(Sales) OVER (PARTITION BY Branch ORDER BY Month) AS Prev_Sales
    FROM monthly_sales
),
growth_percent AS (
    SELECT 
        Branch,
        Month,
        Sales,
        Prev_Sales,
        ROUND(((Sales - Prev_Sales) / Prev_Sales) * 100, 2) AS Growth_Rate
    FROM growth_rate_calc
    WHERE Prev_Sales IS NOT NULL
)
SELECT 
    Branch,
    AVG(Growth_Rate) AS Avg_Monthly_Growth
FROM growth_percent
GROUP BY Branch
ORDER BY Avg_Monthly_Growth DESC
LIMIT 1;

## task 2 
SELECT 
    Branch,
    `Product line`,
    SUM(`gross income`) AS Total_Profit
FROM walmart_dataset
GROUP BY Branch, `Product line`
ORDER BY Branch, Total_Profit DESC;

## task 3
SELECT  `Customer ID`,
    SUM(Total) AS Total_Spend,
    CASE
        WHEN SUM(Total) >= 500 THEN 'High'
        WHEN SUM(Total) BETWEEN 200 AND 499.99 THEN 'Medium'
        ELSE 'Low'
    END AS Spending_Tier
FROM walmart_dataset
GROUP BY `Customer ID`;

## task 4
WITH avg_std AS (
    SELECT 
	`Product line`,
	AVG(Total) AS avg_total,
	STDDEV(Total) AS std_total
    FROM walmart_dataset
    GROUP BY `Product line`
)
SELECT 
    w.*,
    a.avg_total,
    a.std_total
FROM walmart_dataset w
JOIN avg_std a ON w.`Product line` = a.`Product line`
WHERE ABS(w.Total - a.avg_total) > 2 * a.std_total;

## task 5
SELECT 
    City,
    Payment,
    COUNT(*) AS Count
FROM walmart_dataset wd
GROUP BY City, Payment
HAVING COUNT(*) = (
SELECT MAX(cnt)
FROM (
            SELECT 
            City AS sub_city,
            Payment AS sub_payment,
            COUNT(*) AS cnt
        FROM walmart_dataset
        WHERE City = wd.City
        GROUP BY sub_payment
    ) AS subquery
);

##task 6
SELECT 
    MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
    Gender,
    SUM(Total) AS Monthly_Sales
FROM walmart_dataset
GROUP BY Month, Gender
ORDER BY Month;

## task 7
SELECT * FROM (
    SELECT 
        `Customer type`,
        `Product line`,
        Total_Sales,
        RANK() OVER (PARTITION BY `Customer type` ORDER BY Total_Sales DESC) AS 'Rank'
    FROM (
        SELECT 
            `Customer type`,
            `Product line`,
            SUM(Total) AS Total_Sales
        FROM walmart_dataset
        GROUP BY `Customer type`, `Product line`
    ) AS sales_summary
) AS ranked
WHERE 'Rank' = 1;

##task 8
SELECT 
    a.`Customer ID`,
    a.Date AS First_Purchase,
    b.Date AS Repeat_Purchase
FROM walmart_dataset a
JOIN walmart_dataset b 
    ON a.`Customer ID` = b.`Customer ID`
    AND STR_TO_DATE(b.Date, '%d-%m-%Y') > STR_TO_DATE(a.Date, '%d-%m-%Y')
    AND DATEDIFF(STR_TO_DATE(b.Date, '%d-%m-%Y'), STR_TO_DATE(a.Date, '%d-%m-%Y')) <= 30;

## task 9
SELECT 
    `Customer ID`,
    SUM(Total) AS Total_Spent
FROM walmart_dataset
GROUP BY `Customer ID`
ORDER BY Total_Spent DESC
LIMIT 5;

## task 10
SELECT 
DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS Weekday,
SUM(Total) AS Total_Sales
FROM walmart_dataset
GROUP BY Weekday
ORDER BY Total_Sales DESC;

