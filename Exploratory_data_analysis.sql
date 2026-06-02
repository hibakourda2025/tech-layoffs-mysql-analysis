select * from layoff_staging1;

-- total_laid_off
SELECT 
    MAX(total_laid_off),
    MIN(total_laid_off),
    round(AVG(total_laid_off),2)
FROM
    layoff_staging1;

-- percentage_laid_off    
SELECT 
    MAX(percentage_laid_off),
    MIN(percentage_laid_off),
    round(AVG(percentage_laid_off),2)
FROM
    layoff_staging1;
    
select * 
from layoff_staging1
where percentage_laid_off = 1
order by funds_raised_millions desc;

select count(company) 
from layoff_staging1
where percentage_laid_off = 1;

-- funds_raised_millions
SELECT 
    MAX(funds_raised_millions),
    MIN(funds_raised_millions),
    round(AVG(funds_raised_millions),2)
FROM
    layoff_staging1;

select company , sum(total_laid_off)
from layoff_staging1
group by company
order by 2 desc;

select industry , sum(total_laid_off)
from layoff_staging1
group by industry
order by 2 desc;

select country , sum(total_laid_off)
from layoff_staging1
group by country
order by 2 desc
limit 10;

select year(`date`) , sum(total_laid_off)
from layoff_staging1
group by year(`date`)
order by 1;

select substring(`date`,1,7) as "month" , sum(total_laid_off)
from layoff_staging1
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1;

select stage , sum(total_laid_off)
from layoff_staging1
group by stage
order by 1;

select min(`date`) , max(`date`)
from layoff_staging1;

with rolling_total as
(
	select substring(`date`,1,7) as "month" , sum(total_laid_off) as tot_off
	from layoff_staging1
	where substring(`date`,1,7) is not null
	group by substring(`date`,1,7)
	order by 1
)
select `month` , tot_off ,
sum(tot_off) over(order by `month`) as rolling_total
from rolling_total;

with company_year (company,years,total_laid_off) as
(
select company , year(`date`) , sum(total_laid_off)
from layoff_staging1
group by company , year(`date`)
),
company_rank as
(
select * ,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * 
from company_rank
where ranking <=5;












































