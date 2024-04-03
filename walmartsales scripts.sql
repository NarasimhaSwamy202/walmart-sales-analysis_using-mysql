-- download a walmartsalesdata csv file 
-- create a database 
-- import walmartsalesdata dataset

use sales;
rename table walmartsalesdata to walmart;

select * from walmart;
show columns from walmart;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- :::::::::::::::::::::::::::::::::::::::::Feature Engineering

-- *Rename the Tax 5% column
alter table walmart
change column `Tax 5%` `Tax_pct` float(6,4);

-- *Add time_of_day column
-- NOTE: You can disable safe update mode by executing the following command before running your update query:
SET SQL_SAFE_UPDATES = 0;
 
alter table walmart 
add time_of_day varchar(20);

update walmart
set time_of_day = (
	case 
		when time between "00:00:00" and "12:00:00" then "Morning"
        when time between "12:00:01" and "16:00:00" then "Afternoon"
        else "Evening"
	end
);

-- *Add day_name column
alter table walmart
add column day_name varchar(10);

update walmart
set day_name = dayname(walmart.date);

-- *Add Month_name column
alter table walmart
add Month_name varchar(15);

update walmart
set month_name = monthname(date);

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::Generic

-- How many unique cities does the data have?
select count(distinct city) from walmart;

-- In which city is each branch?
select distinct city, branch from walmart;

-- --------------------------------------------------------------------------------------------------------------------------------------
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::Product

-- How many unique product lines does the data have?
select count(distinct `product line`) from walmart;

-- What is the most selling product line
select sum(quantity) as qty, `product line` from walmart group by `product line` order by qty desc;

-- What is the total revenue by month
select month_name, sum(total) as total_revenue from walmart  group by month_name;

-- What month had the largest COGS?
select month_name, sum(cogs) as cogs  from walmart group by month_name order by cogs desc limit 1;

-- What product line had the largest revenue?
select `product line`, sum(total) as total_revenue from walmart group by `product line` order by total_revenue desc limit 1;

-- What is the city with the largest revenue?
select city, sum(total) as total_revenue from walmart group by city order by total_revenue desc limit 1;

-- What product line had the largest VAT(Value added tax)?
select `Product line` from walmart group by `product line` order by sum(tax_pct) desc limit 1;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
select `product line`, 
		case 
			when  avg(quantity) > (select avg(quantity) from walmart) then "Good"
			else "Bad"
		end as remark
from walmart group by `product line`;

-- Which branch sold more products than average product sold?
select branch, sum(quantity) as total_sold from walmart group by branch having total_sold > (select avg(quantity) from walmart);

-- What is the most common product line by gender
select `Product line`, gender, COUNT(*) AS frequency 
from walmart 
group by `Product line`, gender 
order by frequency desc
limit 1;

-- What is the average rating of each product line
select `product line`, round(avg(rating),2) as avg_rating from walmart group by `product line`;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::Customer

-- How many unique customer types does the data have?
select distinct `Customer type` from walmart;

-- How many unique payment methods does the data have?
select distinct Payment from walmart;

-- What is the most common customer type?
select `Customer type`, count(*) as count from walmart group by `Customer type` order by count desc limit 1;

-- Which customer type buys the most?
select `Customer type`, count(*) from walmart group by `Customer type`;

-- What is the gender of most of the customers?
select gender, count(*) as count from walmart group by gender order by count;

-- What is the gender distribution per branch?
select branch, gender, count(*) as count from walmart group by branch, gender;

-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating) as avg_rating from walmart 
group by time_of_day order by avg_rating desc;

-- Which time of the day do customers give most ratings per branch?
select branch, time_of_day, avg(rating) as avg_rating from walmart 
group by branch, time_of_day order by branch, avg_rating desc;

-- Which day fo the week has the best avg ratings?
select day_name as best_avg_rating, avg(rating) as avg_rating from walmart 
group by day_name order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?
select branch, day_name, avg(rating) as avg_rating from walmart 
group by branch, day_name order by branch, avg_rating desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::Sales

-- Number of sales made in each time of the day per weekday 
select day_name, time_of_day, count(*) as count from walmart
group by day_name, time_of_day 
order by field(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), time_of_day;

-- Which of the customer types brings the most revenue?
select `Customer type`, sum(Total) as total_revenue from walmart group by `Customer type` order by total_revenue desc limit 1;

-- Which city has the largest tax/VAT percent?
select City, round(avg(Tax_pct),2) as avg_tax from walmart group by city order by avg_tax desc limit 1;

-- Which customer type pays the most in VAT?
select `Customer type`, round(avg(Tax_pct),2) as avg_tax from walmart group by `Customer type` order by avg_tax desc limit 1;

-- -------------------------------------------------------------------------------------------------------------------------------------------





