create  database project;
use  project;
select * from chefmozaccepts;

-- desc table;
-- Below mentioned are a few questions based on performances of different restaurants, based on different options. 

-- Questions:

-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select * from geoplaces2;
select g.name,count(r.userID)tot_visits,g.alcohol from rating_final r join geoplaces2 g on r.placeID=g.placeID  group by name,alcohol ;


-- Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective
--  price categories as well.
select * from rating_final;
select distinct g.name,g.alcohol,g.price,avg(r.rating) over(partition by g.alcohol,g.price)avg_ratiing from  rating_final r join geoplaces2 g on r.placeID=g.placeID
group by price;

-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol 
-- categories along with the total number of restaurants.
select g.alcohol,p.parking_lot,count(g.name)over(partition by g.alcohol)tot_no_restaurant from chefmozparking p join geoplaces2 g on p.placeID=g.placeID;


-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select distinct count(Rcuisine) from chefmozcuisine;
select distinct alcohol from geoplaces2;

select c.Rcuisine,g.alcohol,count(c.Rcuisine)/count(g.alcohol) over(partition by g.alcohol)per  from chefmozcuisine c join geoplaces2 g on c.placeID=g.placeID group by Rcuisine ;
-- -------------------------------- 
select * , sum(count_restaurant)over(partition by Alcohol) as Total_count , round((count_restaurant / sum(count_restaurant)over(partition by Alcohol)) * 100 , 2)  as percent
from 
(select Alcohol , Cuisine , count(placeID) as count_restaurant from
(select  g.alcohol as Alcohol , placeID , cc.Rcuisine as Cuisine
from geoplaces2 g 
join chefmozcuisine cc
using (placeID)) as t1
group by Alcohol , Cuisine
order by Alcohol) as t2;


-- Let us now look at a different prospect of the data to check state-wise rating.

-- Questions 5: - let’s take out the average rating of each state.
select g.state,avg(r.rating)avg_ratings from rating_final r join geoplaces2 g on r.placeID=g.placeID group by state ;

-- Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the 
-- summary on the basis of State, alcohol, and Cuisine.

select r.*,G.NAME,g.state,g.alcohol,c.Rcuisine from rating_final r join geoplaces2 g on r.placeID=g.placeID  join chefmozcuisine c on r.placeID=c.placeID where state="Tamaulipas";

-- Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and 
-- tried Mexican or Italian types of cuisine, and also their budget level is low.
-- We encourage you to give it a try by not using joins.
select * from usercuisine;
select * from userprofile;
-- --------------------------- 
select up.userID ,g.name,avg(r.food_rating)avg_food_rating,avg(r.service_rating)avg_service_rating,uc.rcuisine,avg(up.weight)
over(partition by rcuisine)avg_weight from userprofile up join rating_final r on up.userid=r.userID 
join usercuisine uc on uc.userid=r.userID join geoplaces2 g on g.placeID=r.placeID
where budget="low" and g.name="KFC" and Rcuisine in("Mexican","italian") group by userID ;

-- Part 3:  Triggers
-- Question 1:
-- Create two called Student_details and Student_details_backup.

-- Table 1: Attributes 		Table 2: Attributes
-- Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.
-- Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the student’s details and Student Details Backup tables. 
-- He / She is deleting the records from the Student details after the students completed the course and keeping the backup in the student details backup table by inserting the 
-- records every time. You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose when he/she delete the records.write a trigger that
--  should be capable enough to insert the student details in the backup table whenever the employee deletes records from the student details table.
-- Note: Your query should insert the rows in the backup table before deleting the records from student details.

create database students;
create table Student_details 
(student_id int not null primary key,
student_name varchar(20),
mail_id varchar(20),
mobile_no varchar(20));
create table Student_details_backup
(student_id int not null,
student_name varchar(20),
mail_id varchar(20),
mobile_no varchar(20),
foreign key (student_id) references Student_details(student_id));
create trigger aft_insert after insert
on student_details for each row 
insert into student_details_backup values 
(new.student_id, new.student_name, new.mail_id, new.mobile_no);
insert into student_details values 
(101, 'ABC', 'pqr@gmail.com', '9887900988');
insert into student_details values 
(102, 'DEF', 'stu@gmail.com', '8393848899'),
(103, 'GHI', 'xyz@gmail.com', '7446788539');
select * from student_details;
select * from student_details_backup;






-- Note: Your query should insert the rows in the backup table before deleting the records from student details.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------

select * from cust_dimen;
-- Question 1: Find the top 3 customers who have the maximum number of orders
select * from market_fact;
select c.customer_name,count(m.ord_id)mx_ord from market_fact m join cust_dimen c on  m.cust_id=c.Cust_id group by Customer_Name  order by mx_ord desc limit 3;

SELECT c.customer_name, COUNT(*) as num_orders
FROM market_fact m join cust_dimen c on  m.cust_id=c.Cust_id group by Customer_Name
ORDER BY num_orders DESC
LIMIT 3;

select * , sum(count_restaurant)over(partition by Alcohol) as Total_count , round((count_restaurant / sum(count_restaurant)over(partition by Alcohol)) * 100 , 2)  as percent
from 
(select Alcohol , Cuisine , count(placeID) as count_restaurant from
(select  g.alcohol as Alcohol , placeID , cc.Rcuisine as Cuisine
from geoplaces2 g 
join chefmozcuisine cc
using (placeID)) as t1
group by Alcohol , Cuisine
order by Alcohol) as t2;



-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select od.Order_ID , od.Order_Date , od.Ord_id , sd.Ship_Date , sd.Ship_Mode , Ship_ID ,
 datediff(str_to_date(Ship_Date , '%d-%m-%Y') , str_to_date(Order_Date , '%d-%m-%Y' )) as Days_TakenForDelivery
from orders_dimen od
join shipping_dimen sd
using (Order_Id)
order by Days_TakenForDelivery desc;




-- Question 3: Find the customer whose order took the maximum time to get delivered.
select * from orders_dimen;
select * from shipping_dimen;
select * from
(select cd.Cust_id , cd.customer_Name , t1.*
from cust_dimen cd
join market_fact mf
using (Cust_id)
join (select od.Order_ID , od.Order_Date , od.Ord_id , sd.Ship_Date , sd.Ship_Mode , Ship_ID ,
 datediff(str_to_date(Ship_Date , '%d-%m-%Y') , str_to_date(Order_Date , '%d-%m-%Y' )) as mx_DaysTakenForDelivery
from orders_dimen od
join shipping_dimen sd
using (Order_Id))  as t1
using (Ord_id)) t2
order by mx_DaysTakenForDelivery desc limit 1;




-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select distinct p.Product_Category,p.Product_Sub_Category,sum(o.sales)  over(partition by p.prod_id)tot_sales from  market_fact o join prod_dimen p on o.Prod_id=p.Prod_id;

-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
select distinct p.Product_Category,sum(o.profit)  over(partition by p.Prod_id)tot_profit from  market_fact o join prod_dimen p on o.Prod_id=p.Prod_id;

-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select 'occurance' as Description , count(*) from 
((select 'count' as Descirption,count(distinct month) cnt from 
(select customer_name,cd.Cust_id,year(str_to_date(Order_Date,'%d-%m-%Y')) year ,month(str_to_date(Order_Date,'%d-%m-%Y')) month 
from cust_dimen cd 
left join market_fact  mf 
on mf.Cust_id = cd.Cust_id 
left join orders_dimen od 
on od.Ord_id=mf.Ord_id order by 1,2,3,4) t 
where year = 2011 
group  by  customer_name,Cust_id 
having cnt>=12 order by 1)) as y
union all    
(select 'total in january' , count(distinct cust_id) from market_fact 
where Ord_id in 
(select Ord_id from orders_dimen 
where year(str_to_date(Order_Date,'%d-%m-%Y'))=2011 and month(str_to_date(Order_Date,'%d-%m-%Y'))=1 ));





