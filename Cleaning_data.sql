SET SQL_SAFE_UPDATES = 0;

select * from layoffs;

create table layoff_staging
like layoffs;

insert layoff_staging
select * from layoffs;

select * from layoff_staging;

-- duplicates

with duplicate_cte as
(
select * ,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging
)
select * 
from duplicate_cte
where row_num >1;

CREATE TABLE `layoff_staging1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_staging1
select * ,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging;

select * from layoff_staging1;

delete
from layoff_staging1 
where row_num > 1;

select * 
from layoff_staging1
where row_num > 1;

-- Standalizing data
update layoff_staging1
set company = trim(company);

select distinct industry
from layoff_staging1
order by 1;

update layoff_staging1
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country from layoff_staging1 order by 1;

update layoff_staging1
set country = 'United States'
where country like 'United States%';

select distinct location, country from layoff_staging1 order by 1;

update layoff_staging1
set location = 'Dusseldorf'
where location like 'DÃ¼sseldorf';

update layoff_staging1
set location = 'Florianopolis'
where location like 'FlorianÃ³polis';

update layoff_staging1
set location = 'Malmo'
where location like 'MalmÃ¶';

update layoff_staging1 
set `date` = str_to_date(`date`,'%m/%d/%YYYY');

select `date` , str_to_date(`date`,'%m/%d/%YYYY') from layoff_staging1;

alter table layoff_staging1
modify column `date` date;

update layoff_staging1
set industry = null
where industry = '';

update layoff_staging1 t1
join layoff_staging1 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null and t2.industry is not null;

delete 
from layoff_staging1
where total_laid_off is null and percentage_laid_off is null;

alter table layoff_staging1
drop column row_num;









