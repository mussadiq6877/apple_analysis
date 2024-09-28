# apple_analysis 
## Project Overview

This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally. By tackling a variety of questions, from basic to complex, you'll demonstrate your ability to write sophisticated SQL queries that extract valuable insights from large datasets.

The project is ideal for data analysts looking to enhance their SQL skills by working with a large-scale dataset and solving real-world business questions.

---schemas of apple_store
DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales; 
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category; -- parent
DROP TABLE IF EXISTS stores; -- parent
---stores table
create table stores(store_id varchar(10) primary key,
	store_name varchar(30),
	city varchar(25),
	country varchar(25)
); 

---category table 

create table category(category_id varchar(10) primary key,
	category_name varchar(25)
);
---products table
create table products(product_id varchar(10) primary key,
	product_name varchar(35),
	category_id	varchar(10), ---foreign key 
	launch_date	 date,
	price float,
	constraint fk_category foreign key (category_id) references category(category_id)
); CREATE TABLE sales
(
sale_id	VARCHAR(15) PRIMARY KEY,
sale_date	DATE,
store_id	VARCHAR(10), -- this fk
product_id	VARCHAR(10), -- this fk
quantity INT,
CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--- sales_table
create table sales(sale_id	varchar(20) primary key,
	sale_date date,
	store_id varchar(10),-- foreign_key 
	product_id varchar(10), -- foreign_key
	quantity int,
   constraint fk_stores foreign key (store_id) references stores(store_id),
   constraint fk_products foreign key (product_id) references products(product_id)
); 
--- warranty_table
create table warranty(claim_id varchar(10) primary key,
	claim_date date,
	sale_id	varchar(15), -- foreign key
	repair_status varchar(20),
	constraint sales_table foreign key(sale_id) references sales(sale_id)
);  


