/* Sales Leaderboard:
You have a table "sales" with columns: "product_id," "sales_date," and "amount." Write a SQL query to find the top 3 
products with the highest total sales amount for each month, along with the corresponding sales month.*/

WITH MonthlySales AS (
  SELECT
    product_id,
    EXTRACT(YEAR FROM sales_date) AS sales_year,
    EXTRACT(MONTH FROM sales_date) AS sales_month,
    SUM(amount) AS total_sales_amount,
    RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sales_date), EXTRACT(MONTH FROM sales_date) ORDER BY SUM(amount) DESC) AS sales_rank
  FROM
    sales
  GROUP BY
    product_id,
    EXTRACT(YEAR FROM sales_date),
    EXTRACT(MONTH FROM sales_date)
)

SELECT
  product_id,
  sales_year,
  sales_month,
  total_sales_amount
FROM
  MonthlySales
WHERE
  sales_rank <= 3;

/*Moving Average:
Given a table "stocks" with columns: "stock_id," "price," and "date," write a SQL query to calculate the 
5-day moving average of the stock prices for each stock_id. 
The moving average should be ordered by the stock_id and date.*/

SELECT
    stock_id,
    date,
    price,
    AVG(price) OVER (PARTITION BY stock_id ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_average
FROM
    stocks
ORDER BY
    stock_id,
    date;

	/*Rank and Partition:
In a table "employees," there are columns: "department," "employee_id," "salary," and "hire_date." 
Write a SQL query to rank employees within each department based on their salary in descending order, 
and then assign a unique rank number to each employee within the department.*/

SELECT
    department,
    employee_id,
    salary,
    hire_date,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM
    employees;

	/*Running Total with Reset:
Given a table "transactions" with columns: "transaction_id," "user_id," "amount," and "transaction_date," 
write a SQL query to calculate the running total of the "amount" for each "user_id." However, if the running total
exceeds a certain amount (e.g., 1000),
the total should reset to 0 and start accumulating again.*/

WITH RECURSIVE CTE AS (
  SELECT
    transaction_id,
    user_id,
    amount,
    transaction_date,
    CASE
      WHEN amount > 1000 THEN 0
      ELSE amount
    END AS capped_amount,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS rn
  FROM
    transactions
  WHERE
    amount <= 1000
  UNION ALL
  SELECT
    t.transaction_id,
    t.user_id,
    CASE
      WHEN t.amount + cte.capped_amount > 1000 THEN 0
      ELSE t.amount + cte.capped_amount
    END AS amount,
    t.transaction_date,
    CASE
      WHEN t.amount + cte.capped_amount > 1000 THEN 0
      ELSE t.amount + cte.capped_amount
    END AS capped_amount,
    t.rn
  FROM
    transactions t
  INNER JOIN
    CTE ON t.user_id = CTE.user_id AND t.transaction_date > CTE.transaction_date AND t.rn = CTE.rn + 1
)
SELECT
  transaction_id,
  user_id,
  amount,
  transaction_date
FROM
  CTE
ORDER BY
  user_id,
  transaction_date;

  /*
  Top N Percentile:
In a table "test_scores" with columns: "student_id," "test_id," and "score," write a SQL query to find the top 
10% of students based on their average test scores. 
The query should return the student_id and their corresponding average score.*/

SELECT
    student_id,
    AVG(score) AS average_score
FROM
    test_scores
GROUP BY
    student_id
HAVING
    AVG(score) >= PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY score) OVER ()
ORDER BY
    average_score DESC;

	/*First Non-Null Value:
You have a table "logs" with columns: "log_id," "user_id," and "activity_date." 
Write a SQL query to find the first activity_date for each user_id when they performed an activity and return the results 
with the user_id and the corresponding first activity_date.*/

SELECT
    user_id,
    MIN(activity_date) AS first_activity_date
FROM
    logs
WHERE
    activity_date IS NOT NULL
GROUP BY
    user_id;

	/*Nth Highest Salary in Each Department:
In a table "employees" with columns: "employee_id," "department_id," and "salary," write a SQL query to 
find the Nth highest salary for each department. The query should return the department_id, Nth highest salary, 
and the corresponding employee_id.*/

WITH RankedSalaries AS (
  SELECT
    department_id,
    employee_id,
    salary,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
  FROM
    employees
)

SELECT
  department_id,
  employee_id,
  salary
FROM
  RankedSalaries
WHERE
  salary_rank = N; -- Replace N with the desired rank value (e.g., 2 for the 2nd highest salary)