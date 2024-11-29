## CREATE TABLE FOR CLEANING

drop table bs_cleaning1;

create table bs_cleaning1
like bs_raw;

insert bs_cleaning1
select*from bs_raw;

## Fixing Column Names,Dropping Useless Columns

alter table bs_cleaning1
change column `Sales_Order #` Sales_Order_Num int;

alter table bs_cleaning1
drop column `Date`;

alter table bs_cleaning1
drop column Product_Category;

## Trimming & Formatting

update bs_cleaning1
set Sales_Order_Num = TRIM(Sales_Order_Num);

update bs_cleaning1
set `Day` = TRIM(`Day`);

select distinct(`Day`)
from bs_cleaning1
order by 1;

update bs_cleaning1
set `Month` = TRIM(`Month`);

select distinct(`Month`)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Month = 'December'
where Month like '%Dec%';

update bs_cleaning1
set `Year` = TRIM(`Year`);

select distinct(`Year`)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Customer_Age = TRIM(Customer_Age);

select distinct(Customer_Age)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Age_Group = TRIM(Age_Group);

select distinct(Age_Group)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Customer_Gender = TRIM(Customer_Gender);

select distinct(Customer_Gender)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Country = TRIM(Country);

select distinct(Country)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Country = 'United States'
where Country like '%States%';

update bs_cleaning1
set State = TRIM(State);

select distinct(State)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Sub_Category = TRIM(Sub_Category);

select distinct(Sub_Category)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Product_Description = TRIM(Product_Description);

select distinct(Product_Description)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Product_Description = TRIM('Mountain-' from Product_Description);

update bs_cleaning1
set Order_Quantity = TRIM(Order_Quantity);

select distinct(Order_Quantity)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Unit_Cost = TRIM(Unit_Cost);

select distinct(Unit_Cost)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Unit_Cost = TRIM('$' from Unit_Cost);

update bs_cleaning1
set Unit_Cost = replace(Unit_Cost,'.00','');

update bs_cleaning1
set Unit_Cost = replace(Unit_Cost,',','');

update bs_cleaning1
set Unit_Price = TRIM(Unit_Price);

select distinct(Unit_Price)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Unit_Price = TRIM('$' from Unit_Price);

update bs_cleaning1
set Unit_Price = replace(Unit_Price,'.00','');

update bs_cleaning1
set Unit_Price = replace(Unit_Price,',','');

update bs_cleaning1
set Profit = TRIM(Profit);

select distinct(Profit)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Profit = TRIM('$' from Profit);

update bs_cleaning1
set Profit = replace(Profit,'.00','');

update bs_cleaning1
set Profit = replace(Profit,',','');

update bs_cleaning1
set Cost = TRIM(Cost);

select distinct(Cost)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Cost = TRIM('$' from Cost);

update bs_cleaning1
set Cost = replace(Cost,'.00','');

update bs_cleaning1
set Cost = replace(Cost,',','');

update bs_cleaning1
set Revenue = TRIM(Revenue);

select distinct(Revenue)
from bs_cleaning1
order by 1;

update bs_cleaning1
set Revenue = TRIM('$' from Revenue);

update bs_cleaning1
set Revenue = replace(Revenue,'.00','');

update bs_cleaning1
set Revenue = replace(Revenue,',','');

alter table bs_cleaning1
change column Sales_Order_Num Sales_Order_Num bigint;

alter table bs_cleaning1
change column Unit_Cost Unit_Cost bigint;

alter table bs_cleaning1
change column Unit_Price Unit_Price bigint;

alter table bs_cleaning1
change column Profit Profit bigint;

alter table bs_cleaning1
change column Cost Cost bigint;

alter table bs_cleaning1
change column Revenue Revenue bigint;

drop table bs_cleaning2;

create table bs_cleaning2
like bs_cleaning1;

insert bs_cleaning2
select*from bs_cleaning1;

## DELETE DUPLICATES

select count(*) as count,`Sales_Order_Num`
from bs_cleaning2
group by `Sales_Order_Num`
having count(*) > 1;

drop table bs_cleaning3;

create table bs_cleaning3
like bs_cleaning2;

alter table bs_cleaning3
drop column count;

alter table bs_cleaning3
add count int;

insert into bs_cleaning3
	select*,row_number() over(partition by Sales_Order_Num,`Day`,`Month`,`Year`,
	Customer_Age,Age_Group,Customer_Gender,Country,State,
	Sub_Category,Order_Quantity,Unit_Cost,Unit_Price,
	Profit,Cost,Revenue) as count
	from bs_cleaning2;
    
delete from bs_cleaning3
where count>1;

alter table bs_cleaning3
drop column count;

select count(*) as count,`Sales_Order_Num`
from bs_cleaning3
group by `Sales_Order_Num`
having count(*) > 1;

select*from bs_cleaning3
where `Sales_Order_Num`=261695;

select*from bs_cleaning3;

## 261696 is skipped

drop table bs_cleaning4;

create table bs_cleaning4
like bs_cleaning3;

alter table bs_cleaning4
drop column count;

alter table bs_cleaning4
add count int;

insert into bs_cleaning4
	select*,row_number() over(partition by Sales_Order_Num) as count
	from bs_cleaning3;
    
select*from bs_cleaning4
where count>1;

update bs_cleaning4
set Sales_Order_Num = 261696
where count=2;

alter table bs_cleaning4
drop column count;

## Fix Blanks & Zeroes

drop table bs_cleaning5;

create table bs_cleaning5
like bs_cleaning4;

insert into bs_cleaning5
select*from bs_cleaning4;

update bs_cleaning5
set Age_Group = "Adults (35-64)"
where Customer_Age>=35 and Customer_Age<64;

select*from bs_cleaning5
where unit_cost=0;

select*from bs_cleaning5
where Product_Description='200 Black, 46';

update bs_cleaning5
set Unit_Cost = 1252
where Product_Description='200 Black, 46';

update bs_cleaning5
set Product_Description='200 Black, 46' 
where unit_cost=1252;

select*from bs_cleaning5
where Unit_Price=0;

select*from bs_cleaning5
where Product_Description='400-W Silver, 42';

update bs_cleaning5
set Unit_Price = 769
where Product_Description='400-W Silver, 42';

select*from bs_cleaning5
where Profit=0;

select*from bs_cleaning5
where Cost=0;

update bs_cleaning5
set Cost = Unit_Cost*Order_Quantity;

select*from bs_cleaning5
where Revenue=0;

update bs_cleaning5
set Revenue = Unit_Price*Order_Quantity;

drop table bs_cleaned;

create table bs_cleaned
like bs_cleaning5;

insert into bs_cleaned
select*from bs_cleaning5;

## SPLITTING COLUMNS TO GET MORE PRECISE INFORMATION

alter table bs_cleaned
add Color text after Product_Description;
alter table bs_cleaned
add Rim_Size int after Product_Description;
alter table bs_cleaned
add Model text after Product_Description;

update bs_cleaned
set Color = substring_index(substring_index(product_description,',',1),' ',-1);
update bs_cleaned
set Model = substring_index(product_description,' ',1);
update bs_cleaned
set Rim_Size = substring_index(product_description,' ',-1);
alter table bs_cleaned
drop column Product_Description;

drop table bs_cleaning1;
drop table bs_cleaning2;
drop table bs_cleaning3;
drop table bs_cleaning4;
drop table bs_cleaning5;
select*from bs_cleaned;