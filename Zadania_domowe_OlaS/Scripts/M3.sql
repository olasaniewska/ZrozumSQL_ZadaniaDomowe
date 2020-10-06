--Zadanie 1
--CREATE SCHEMA training;

--Zadanie 2
--ALTER SCHEMA training RENAME TO training_zs;

--Zadanie 3
/*
CREATE TABLE training_zs.products(
id int,
production_qty numeric(10,2),
product_name varchar(100),
product_code char(10),
description text,
manufacturing_date date
);
*/

--Zadanie 4
--ALTER TABLE training_zs.products ADD CONSTRAINT pk_products PRIMARY KEY (id);

--Zadanie 5
--DROP TABLE IF EXISTS sales;

--Zadanie 6
/*CREATE TABLE training_zs.sales(
id int PRIMARY KEY,
sales_date timestamp NOT NULL,
sales_amount numeric(38,2),
sales_qty numeric(10,2),
product_id int,
added_by text DEFAULT 'Admin',
CONSTRAINT sales_over_1k CHECK (sales_amount > 1000)
);
*/

--Zadanie 7
--ALTER TABLE sales ADD FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

--Zadanie 8
--DROP SCHEMA training_zs CASCADE;



