use telecom_churn;

select * from churn__data;
select * from customer_data;
select * from internet_data;

-- Calculate the overall churn rate from the main customer data --
SELECT SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) *100 / COUNT(Churn)
FROM churn_data;

-- Find the average monthly charges for churned vs non-churned customers --
SELECT AVG(MonthlyCharges) AS Avg_Monthly_Charges_Churned
FROM churn_data
GROUP BY Churn
HAVING Churn = 'Yes';

-- List top 5 payment methods with the highest churn rates --
SELECT PaymentMethod, SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) *100 / COUNT(Churn) AS Churn_rate
FROM churn_data
GROUP BY PaymentMethod
ORDER BY Churn_rate
LIMIT 5;

-- Display the number of customers on each contract type who have churned --
SELECT Contract, COUNT(*) AS ChurnCount
FROM churn_data
WHERE Churn = 'Yes'
GROUP BY Contract;

-- Count how many customers have tenure less than 12 months and have churned --
SELECT tenure,  COUNT(*) AS ChurnCount
FROM churn_data
WHERE tenure < 12 AND Churn = 'Yes'
GROUP BY tenure;

-- Identify how many customers have paperless billing and are paying through electronic check --
SELECT COUNT(*) AS ChurnCount
FROM churn_data
WHERE PaperlessBilling = 'Yes' AND PaymentMethod = 'Electronic check';

-- Calculate the total revenue generated from non churned customrs only --
SELECT SUM(TotalCharges) AS Rev_By_NonChurned
FROM churn_data
WHERE Churn = 'No';

-- List customers who have never used phoneservice or internetservice --
SELECT COUNT(C.customerID) AS Customers
FROM churn_data C
INNER JOIN internet_data T
ON C.customerID = T.customerID
WHERE C.PhoneService = 'No' OR T.InternetService = 'No';

-- 
-- Find the number of customers with month to month contracts and no online security --
SELECT COUNT(C.customerID) AS Customers
FROM churn_data C
INNER JOIN internet_data I
ON C.customerID = I.customerID
WHERE C.Contract = 'Month-to-month' AND I.OnlineSecurity = 'No';

-- Show the churn rate grouped by senior citizen status --
SELECT SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) *100 / COUNT(Churn) AS Churn_rate, T.SeniorCitizen
FROM churn_data C
INNER JOIN customer_data T
ON C.customerID = T.customerID
GROUP BY T.SeniorCitizen;

-- Determine the average customer age for churned and non-churned customers --
SELECT AVG(T.Age) AS Avg_age_Churn
FROM customer_data T
INNER JOIN churn_data C
ON T.customerID = C.customerID
WHERE C.Churn = 'Yes';

SELECT AVG(T.Age) AS Avg_age_NonChurn
FROM customer_data T
INNER JOIN churn_data C
ON T.customerID = C.customerID
WHERE C.Churn = 'No';

-- List customers with Fiber optic internet who are using all entertainment services (StreamingTV and StreamingMovies) --
SELECT customerID
FROM internet_data
WHERE InternetService = 'Fiber optic' AND StreamingTV = 'Yes' AND StreamingMovies = 'Yes';

-- Identify the top 5 customers who have paid the highest total charges but still churned --
SELECT customerID, TotalCharges
FROM churn_data
WHERE Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 5;

-- Find customers who are not senior now, but will turn 60 within the next 2 year --
SELECT customerID
FROM customer_data
WHERE SeniorCitizen = 0 AND Age BETWEEN 57 AND 59;

-- Get a list of customers who are using all possible services.(phone,internet,backup,security,streaming,techsupport)
SELECT I.customerID
FROM internet_data I
INNER JOIN churn_data C
ON I.customerID = C.customerID
WHERE C.PhoneService = 'Yes' AND InternetService <> 'No' AND OnlineSecurity = 'Yes' AND OnlineBackup = 'Yes' AND TechSupport = 'Yes' AND StreamingTV = 'Yes' AND StreamingMovies = 'Yes';

-- Calculate the churn rate by age group: <30, 30-50, 50-64, 65+ --
SELECT CASE 
WHEN Age < 30 THEN '<30'
WHEN Age BETWEEN 30 AND 50 THEN '30-50'
WHEN Age BETWEEN 50 AND 64 THEN '50-64'
ELSE '65+'
END AS AgeGroup,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(Churn) AS Churn_rate
FROM churn_data C
INNER JOIN customer_data T
ON C.customerID = T.customerID
GROUP BY AgeGroup;

-- Using a subquery, find customers whose total charges are above the average of all churned customers --
SELECT customerID
FROM churn_data
WHERE TotalCharges > 
(
SELECT AVG(TotalCharges)
FROM churn_data
WHERE Churn = 'Yes'
);

-- Determine the correlation between long tenure(>=24 months) and churn. Do loyal customer churn less? --
SELECT CASE
WHEN tenure >= 24 THEN 'Long_tenure' ELSE 'Short_tenure' END AS Tenure_level,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(Churn) AS Churn_rate
FROM churn_data
GROUP BY Tenure_level;

-- Create a report showing monthly churn trend - how many customers churned each month --








-- Rank customer by revenue(total Charges) within each contract type using window function --
SELECT customerID, Contract, TotalCharges,
RANK() OVER (PARTITION BY Contract ORDER BY TotalCharges DESC) AS revenue_rank
FROM churn_data;

-- Using a CTE, list customers who have either no protection services (OnlineSecurity, Backup, DeviceProtection) and have churned --
WITH unprotected_customers AS (
SELECT *
FROM internet_data I
WHERE OnlineSecurity = 'No'
OR OnlineBackup = 'No'
OR DeviceProtection = 'No'
)
SELECT *
FROM unprotected_customers U
INNER JOIN churn_data C
ON C.customerID = U.customerID
WHERE Churn = 'Yes';

SELECT 
    customerID,
    Age,
    60 - Age AS Years_Left_To_Senior,
    FLOOR((60 - Age) * 12) AS Months_Left_To_Senior,
    FLOOR((60 - Age) * 365.25) AS Days_Left_To_Senior
FROM 
    customer_data
WHERE 
    Age < 60;












