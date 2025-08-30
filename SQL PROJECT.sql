CREATE SCHEMA Project;
USE Project;
SELECT *FROM churn_data;
SELECT*FROM customer_data;
SELECT *FROM internet_data;
#1.	Calculate the overall churn rate from the main customer data.
select count(customerID) as total_customers, 
sum(case when churn="Yes"then 1 else 0 end ) as churned_customers,
round(sum(case when churn="Yes" then 1 else 0 end)/count(*),4) as churn_rate
from churn_data;
#2.	Find the average monthly charges for churned vs non-churned customers.
select Round(Avg(MonthlyCharges),2) as avg_monthly_charges
from churn_data
where churn="Yes";
select Round(Avg(MonthlyCharges),2) as avg_monthly_charges
from churn_data
where churn="No";
# Another method
SELECT 
  Churn,
  ROUND(AVG(MonthlyCharges), 2) AS AvgMonthlyCharges
FROM churn_data
GROUP BY Churn;
#3.	List the top 5 payment methods with the highest churn rates.
select PaymentMethod, count(customerID) as total_customers, 
sum(case when churn="Yes"then 1 else 0 end ) as churned_customers,
round(sum(case when churn="Yes" then 1 else 0 end)/count(*),4) as churn_rate
from churn_data
group by PaymentMethod
order by churn_rate DESC
LIMIT 5;
#4.	Display the number of customers on each contract type who have churned.
select Contract,
count(*) customerID
from churn_data
where Churn="Yes"
group by Contract;
#5.	Count how many customers have tenure less than 12 months and have churned.
select count(*)  as churn_under_12_months
from churn_data
where churn="Yes"
and tenure<12;
#6.	Identify how many customers have paperless billing and are paying through electronic check.
select count(*) as required_customers
from churn_data
where PaperlessBilling="Yes"
and PaymentMethod="Electronic check";
#7.	Calculate the total revenue generated from non-churned customers only.
select sum(TotalCharges) as Revenue from churn_data
where Churn="No";
#8.	List customers who have never used phone service or internet service.
Select ch.customerID
from churn_data as ch
join internet_data as i 
on ch.customerID=i.customerID
where InternetService="No" 
and PhoneService="No";
#9.	Find the number of customers with ‘Month-to-month’ contracts and no online security.
Select count(*) as required_customers2
from churn_data as ch
join internet_data as i 
on ch.customerID=i.customerID
where Contract="Month-to-month" 
and OnlineSecurity="No";
#10. Show the churn rate grouped by senior citizen status.
select count(c.customerID) as total_customers, 
sum(case when churn="Yes"then 1 else 0 end ) as churned_customers,
round(sum(case when churn="Yes" then 1 else 0 end)/count(*),4) as churn_rate
from churn_data as ch
join customer_data as c
group by SeniorCitizen ="Yes";
# Another method
SELECT
  c.SeniorCitizen,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(
    100.0 * SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS churn_rate_percentage
FROM customer_data c
JOIN churn_data ch ON c.customerID = ch.customerID
GROUP BY c.SeniorCitizen;

#11.	Determine the average customer age for churned vs non-churned customers.
select Round(Avg(Age),2) as avg_age_churn 
from customer_data as c
join churn_data as ch
on c.customerID=ch.customerID
where churn="Yes";
select Round(Avg(Age),2) as avg_age_churn 
from customer_data as c
join churn_data as ch
on c.customerID=ch.customerID
where churn="No";
#12.	List customers with Fiber optic internet who are using all entertainment services (StreamingTV and StreamingMovies).
Select c.customerID from customer_data as c join internet_data as i 
on c.customerID=i.customerID
where InternetService="Fiber optic" and StreamingMovies="No" and StreamingTV="No";
#13.	Identify the top 5 customers who have paid the highest total charges but still churned
Select customerID, TotalCharges
from churn_data 
where churn="Yes"
Order by TotalCharges DESC
LIMIT 5;
#14.	Find customers who are not senior citizens now, but will turn 65 within the next 2 years.
select customerID,Age from customer_data
where Age+2=65 ;
#15.Get a list of customers who are using all possible services (phone, internet, backup, security, streaming, tech support).
Select ch.customerID from churn_data as ch join internet_data as i 
on ch.customerID=i.customerID
where PhoneService="Yes" and InternetService!="No"
and OnlineBackup="Yes" and OnlineSecurity="Yes"
and StreamingMovies="Yes" and StreamingTV="Yes"
and TechSupport="Yes";
# Join two table
select *
from churn_data as c
join customer_data as cu
on c.customerID=cu.customerID;
#16.	Calculate the churn rate by age group: <30, 30–50, 51–64, 65+.
SELECT
  age_group,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(
    100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS churn_rate_percentage
FROM (
  SELECT
    c.customerID,
    c.Age,
    ch.Churn,
    CASE
      WHEN c.Age < 30 THEN '<30'
      WHEN c.Age BETWEEN 30 AND 50 THEN '30–50'
      WHEN c.Age BETWEEN 51 AND 64 THEN '51–64'
      WHEN c.Age >= 65 THEN '65+'
      ELSE 'Unknown'
    END AS age_group
  FROM customer_data c
  JOIN churn_data ch ON c.customerID = ch.customerID
) grouped
GROUP BY age_group
ORDER BY
  CASE age_group
    WHEN '<30' THEN 1
    WHEN '30–50' THEN 2
    WHEN '51–64' THEN 3
    WHEN '65+' THEN 4
    ELSE 5
  END;
  #17.	Using a subquery,find customers whose total charges are above the average of all churned customers
  SELECT *
FROM churn_data
WHERE TotalCharges > (
    SELECT AVG(TotalCharges)
    FROM churn_data
    WHERE Churn = 'Yes'
);
#18.	Determine the correlation between long tenure (>= 24 months) and churn. Do loyal customers churn less?
  SELECT
  CASE 
    WHEN tenure >= 24 THEN 'Tenure >= 24 months'
    ELSE 'Tenure < 24 months'
  END AS TenureCategory,
  COUNT(*) AS customer_count,
  ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percentage
FROM churn_data
GROUP BY TenureCategory;
#19.	Create a report showing monthly churn trend — how many customers churned each month
SELECT 
  CONCAT(year, '-', LPAD(month, 2, '0')) AS YearMonth,
  COUNT(*) AS ChurnedCustomers
FROM customer_data c
JOIN churn_data ch ON c.customerID = ch.customerID
WHERE ch.Churn = 'Yes'
GROUP BY year, month
ORDER BY year, month;
# 20.	Rank customers by revenue (total charges) within each contract type using window functions
SELECT 
  customerID,
  Contract,
  TotalCharges,
  RANK() OVER (
    PARTITION BY Contract
    ORDER BY TotalCharges DESC
  ) AS RevenueRank
FROM churn_data;

#21.	Using a CTE, list customers who have either no protection services (OnlineSecurity, Backup, DeviceProtection) and have churned
SELECT 
  customerID,
  Contract,
  TotalCharges,
  RANK() OVER (
    PARTITION BY Contract 
    ORDER BY TotalCharges DESC
  ) AS RevenueRank
FROM churn_data;
WITH UnprotectedChurners AS (
  SELECT 
    i.customerID,
    ch.Churn,
    i.OnlineSecurity,
    i.OnlineBackup,
    i.DeviceProtection
  FROM internet_data i
  JOIN churn_data ch ON i.customerID = ch.customerID
  WHERE 
    i.OnlineSecurity = 'No' AND
    i.OnlineBackup = 'No' AND
    i.DeviceProtection = 'No' AND
    ch.Churn = 'Yes'
)

SELECT * FROM UnprotectedChurners;
#22.	I want a to check how many days, month and year is left for each and every employee to reach the Senior Citizen
SELECT
  customerID,
  Age,
  CASE 
    WHEN Age >= 60 THEN 0
    ELSE 60 - Age
  END AS YearsLeft,
  CASE 
    WHEN Age >= 60 THEN 'Senior Citizen'
    ELSE CONCAT(
      FLOOR((60 - Age) * 12), ' months (approx)'
    )
  END AS TimeLeftToSeniorCitizen
FROM customer_data;
