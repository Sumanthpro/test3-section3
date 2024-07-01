#### Schemas
create database db_test
go
use db_test

CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00);


--### Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.
select *
from artists
select *
from artworks;
select *
from sales;
select artist_id, upper(name), country, birth_year
from artists;


--2. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
select top(2)
    s.artwork_id, title, price, sum(quantity) as quantity
from artworks a inner join sales s
    on a.artwork_id=s.artwork_id
group by s.artwork_id,title,price
order by price desc,quantity

--3. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select title, sum(total_amount) as total_amount
from artworks a inner join sales s
    on a.artwork_id=s.artwork_id
where title='Mona Lisa'
group by title

--4. Write a query to extract the year from the sale date of 'Guernica'.
select s.sale_id, a.artwork_id, title, year(sale_date) as year
from artworks a inner join sales s
    on a.artwork_id=s.artwork_id
where title='Guernica'

--### Section 2: 2 marks each

--5. Write a query to find the artworks that have the highest sale total for each genre.
with
    cte_aa
    as
    (
        select a.artwork_id, rank() over(partition by genre order by total_amount desc) as rank
        from artworks a inner join sales s
            on a.artwork_id=s.artwork_id
    )

select a.artwork_id, title, genre, sum(total_amount)
from artworks a inner join sales s
    on a.artwork_id=s.artwork_id
    join cte_aa
    on s.artwork_id=cte_aa.artwork_id
where rank=1
group by genre,a.artwork_id,title

--6. Write a query to rank artists by their total sales amount and display the top 3 artists.
select top(3)
    a.artwork_id, a.artist_id, name, rank() over(partition by s.artwork_id order by total_amount desc) as rank
from artists b left join artworks a
    on b.artist_id=a.artist_id
    join sales s
    on a.artwork_id=s.artwork_id
order by total_amount desc

select *
from artists
select *
from artworks;
select *
from sales;
select a.artwork_id, a.artist_id
from artists b left join artworks a
    on b.artist_id=a.artist_id
    join sales s
    on a.artwork_id=s.artwork_id
order by total_amount desc

--7. Write a query to display artists who have artworks in multiple genres.
select a.artist_id, name, a.genre
from artists b left join artworks a
    on b.artist_id=a.artist_id
    join artworks c
    on a.artist_id=c.artist_id
where a.genre<>c.genre

--8. Write a query to find the average price of artworks for each artist.
select a.artwork_id, name, avg(total_amount) as average_sales
from artists b left join artworks a
    on b.artist_id=a.artist_id
    join sales s
    on a.artwork_id=s.artwork_id
group by a.artwork_id,name

--9. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
create nonclustered index artwork_id on sales(artwork_id);
select *
from sales

--10. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
select a.artist_id, name, avg(total_amount) as average_sales
from artists b left join artworks a
    on b.artist_id=a.artist_id
    join sales s
    on a.artwork_id=s.artwork_id
group by a.artist_id,name
having avg(total_amount)>(select avg(total_amount)
from sales)

--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

select *
from artists
select *
from artworks;
select *
from sales;
    select a.artist_id, title, genre
    from artists b left join artworks a
        on b.artist_id=a.artist_id
    where genre='Cubism'
intersect
    select a.artist_id, title, genre
    from artists b left join artworks a
        on b.artist_id=a.artist_id
    where genre='Surrealism';
--12. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

select artist_id, name, birth_year
from artists
where (birth_year)<(select avg(birth_year)
from artists )
--13. Write a query to find the artworks that have been sold in both January and February 2024.
select *
from artists
select *
from artworks;
select *
from sales;
    select a.artwork_id , title, sale_date
    from artworks a inner join sales s
        on a.artwork_id=s.artwork_id
    where format(sale_date,'MM-yyyy')='01-2024'

intersect
    select a.artwork_id , title, sale_date
    from artworks a inner join sales s
        on a.artwork_id=s.artwork_id
    where format(sale_date,'MM-yyyy')='02-2024';

--14. Write a query to calculate the price of 'Starry Night' plus 10% tax.
select title, price+price*0.1  as price
from artworks
where title='Starry Night'

--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

select a.artist_id, name, avg(price) as average_sales
from artists b left join artworks a
    on b.artist_id=a.artist_id
group by a.artist_id,name
having avg(price)>(select sum(price)
from artworks
where genre='Renaissance')

--### Section 3: 3 Marks Questions

--16. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select *
from artists
select *
from artworks;
select *
from sales;

select artwork_id, price
from artworks
where artist_id in (select artist_id
from artworks
where price>(select avg(price)
from artworks))

--17. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.

select artist_id, title, avg(price) as price
from artworks
group by artist_id,title,price
having price>(select avg(price)
from artworks)

--18. Write a query to create a view that shows artists who have created artworks in multiple genres.
create view vm_multigenre
as
    (
    select a.artist_id, name, a.genre
    from artists b left join artworks a
        on b.artist_id=a.artist_id
        join artworks c
        on a.artist_id=c.artist_id
    where a.genre<>c.genre

)
select *
from vm_multigenre
--### Section 4: 4 Marks Questions

--19. Write a query to convert the artists and their artworks into JSON format.
select *
from artists
select *
from artworks;
select *
from sales;
select a.artist_id as 'artistdetails.id',
    name as 'artistdetails.name',
    country as 'artistdetails.country',
    birth_year as 'artistdetails.birth_year',
    artwork_id as 'artworkdetails.id',
    title as 'artworkdetails.title',
    genre as 'artworkdetails.genre',
    price as 'artworkdetails.price'
from artists a inner join artworks b
    on a.artist_id=b.artist_id
for json path,root('artist_details')

    --20. Write a query to export the artists and their artworks into XML format.
    select a.artist_id as [artistdetails/id],
        name as [artistdetails/name],
        country as [artistdetails/country],
        birth_year as [artistdetails/birth_year],
        artwork_id as [artworkdetails/id],
        title as [artworkdetails/title],
        genre as [artworkdetails/genre],
        price as [artworkdetails/price]
    from artists a inner join artworks b
        on a.artist_id=b.artist_id
    for xml path('artist'),root('artist_details')

        --### Section 5: 5 Marks Questions

        --21. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.

        --22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
        select *
        from artists
        select *
        from artworks;
        select *
        from sales;
        alter function dbo.average_sales(@genre nvarchar(max))
returns decimal(10,2)
as 
begin
            return(select avg(total_amount) as average_sales
            from artworks a inner join sales s
                on a.artwork_id=s.artwork_id
            where genre=@genre
            group by genre )
        end
 go
        select dbo.average_sales('Impressionism') as average_sales
        --23. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
        alter procedure sp_update
            @sale_id int,
            @artwork_id int,
            @sale_date date,
            @quantity int,
            @total_amount decimal(20,2)
        as
begin
            begin transaction
            begin try
	   if(exists(select sale_id
            from sales
            where sale_id=@sale_id))
	   throw 500000,'sale_id is already exists',1
	   if(@quantity<=-1)
	   throw 500000,'enter a positive ,non-zero value',1
	   insert into sales
            values(@sale_id, @artwork_id, @sale_date, @quantity, @total_amount)
	   
  commit transaction;
	 end try
	   begin catch
	     print concat('error_line',' ',error_number())
		 print 'error_message :'+error_message()
		 print concat('error_seviraity;'' ',error_state())
		rollback transaction;
	  end catch
            select sum(total_amount) as updated_sales
            from sales
            group by artwork_id
            having artwork_id=@artwork_id;
        end 
go
        exec sp_update 7,2,'2024-03-22',3,3000000;
        select *
        from sales

        --24. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.
        alter  function dbo.total_quantity()
returns @t_q table(genre nvarchar(max),
            total_quantity int)
as
begin
            insert into @t_q
            select genre, sum(quantity) as total_amount
            from artworks a inner join sales s
                on a.artwork_id=s.artwork_id
            group by genre
            return
        end
go
        select *
        from dbo.total_quantity()


        --25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
        select sale_id, ntile(4) over(order by total_amount) as ntile1, total_amount
        from sales

        --### Normalization (5 Marks)

        --26. **Question:**
        --    Given the denormalized table `ecommerce_data` with sample data:

        --| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
        --| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
        --| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
        --| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
        --| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
        --| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

        --Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.
        create table customers
        (
            customer_id int primary key not null,
            customer_name nvarchar(max) not null ,
            customer_email nvarchar(max) not null unique,
        )
        create table products
        (
            product_id int primary key not null,
            customer_id int not null,
            category_id int foreign key references category,
            product_name nvarchar(max) not null unique,
            product_price int not null check(product_price>=0)
        )

        drop table customers
        create table category
        (
            category_id int primary key not null ,
            category_name nvarchar(max) not null unique
        )
        drop table category
        create table orders
        (
            order_id int primary key not null,
            product_id int foreign key references products not null,
            order_quantity int not null check(order_quantity>0),
            order_total_amount decimal not null check(order_total_amount>=0)
        )




--### ER Diagram (5 Marks)