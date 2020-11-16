/*********************************************************************************************************************************/
/************************************************************* MODUL 7 ***********************************************************/
/*********************************************************************************************************************************/

DROP SCHEMA IF EXISTS modul7 CASCADE;

CREATE SCHEMA modul7;

DROP TABLE IF EXISTS modul7.products, modul7.sales, modul7.product_manufactured_region CASCADE;

CREATE TABLE modul7.products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),	
	manufactured_date DATE,
	product_man_region INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE modul7.sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE modul7.product_manufactured_region (
	id SERIAL,
	region_name VARCHAR(25),
	region_code VARCHAR(10),
	established_year INTEGER
);

INSERT INTO modul7.product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('EMEA', 'E_EMEA', 2010),
	  		 ('EMEA', 'W_EMEA', 2012),
	  		 ('APAC', NULL, 2019),
	  		 ('North America', NULL, 2012),
	  		 ('Africa', NULL, 2012);

INSERT INTO modul7.products (product_name, product_code, product_quantity, manufactured_date, product_man_region)
     SELECT 'Product '||floor(random() * 10 + 1)::int,
            'PRD'||floor(random() * 10 + 1)::int,
            random() * 10 + 1,
            CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date),
            CEIL(random()*(10-5))::int
       FROM generate_series(1, 10) s(i);  
      
INSERT INTO modul7.sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 10000) s(i);  
  
      
--Modu� 7 - Zadanie 1
--Korzystaj�c z konstrukcji INNER JOIN po��cz dane sprzeda�owe (SALES, sal_prd_id) z
--danymi o produktach (PRODUCTS, id). W wynikach poka� tylko te produkty, kt�re
--powsta�y w regionie EMEA. Wyniki ogranicz do 100 wierszy.

SELECT
	s.*,
	pr.*,
	pmr.region_name
FROM
	modul7.sales AS s
INNER JOIN modul7.products AS pr ON
	s.sal_prd_id = pr.id
INNER JOIN modul7.product_manufactured_region pmr ON
	pr.product_man_region = pmr.id
AND
	pmr.region_name = 'EMEA'
LIMIT 100;
     

--Modu� 7 - Zadanie 2
--Korzystaj�c z konstrukcji LEFT JOIN po��cz dane o produktach (PRODUCTS,
--product_man_region) z danymi o regionach w kt�rych produkty powsta�y
--(PRODUCT_MANUFACTURED_REGION, id) 

--W wynikach wy�wietl wszystkie atrybuty z tabeli produkt�w i atrybut REGION_NAME
--z tabeli PRODUCT_MANUFACTURED_REGION. Dodatkowo w trakcie z��czenia
--ogranicz dane brane przy z��czenia do tych region�w, kt�re zosta�y za�o�one po 2012 roku.

SELECT
	pr.*,
	pmr.region_name
	--,pmr.established_year --do sprawdzenia
FROM
	modul7.products AS pr
LEFT JOIN modul7.product_manufactured_region AS pmr ON
	pr.product_man_region = pmr.id
AND
	pmr.established_year > 2012;
      

--Modu� 7 - Zadanie 3
--Korzystaj�c z konstrukcji LEFT JOIN po��cz dane o produktach (PRODUCTS,
--product_man_region) z danymi o regionach w kt�rych produkty powsta�y
--(PRODUCT_MANUFACTURED_REGION, id). 

--W wynikach wy�wietl wszystkie atrybuty z tabeli produkt�w i atrybut REGION_NAME
--z tabeli PRODUCT_MANUFACTURED_REGION.       
      
--Dodatkowo wyfiltruj dane wynikowe taki spos�b, aby pokaza� tylko te produkty, dla
--kt�rych regiony, w kt�rych powsta�y zosta�y za�o�one po 2012 roku.
--Por�wnaj te wyniki z wynikami z zadania 2.

SELECT
	pr.*,
	pmr.region_name
	--,pmr.established_year --do sprawdzenia
FROM
	modul7.products AS pr
LEFT JOIN modul7.product_manufactured_region AS pmr ON
	pr.product_man_region = pmr.id
WHERE
	pmr.established_year > 2012;
   
/* W zadaniu drugim (gdzie w trakcie z��czenia ograniczono dane) zwr�cone zosta�y dane dla kt�rych regiony zosta�y za�o�one po 2012 roku oraz te dane, kt�rych daty za�o�enia regionu nie by�y podane (NULL)
 * W zadaniu trzecim zwr�cone zosta�y dane dla kt�rych regiony zosta�y za�o�one tylko i wy��cznie po 2012 roku
 */


--Modu� 7 - Zadanie 4
--Korzystaj�c z konstrukcji RIGHT JOIN po��cz dane sprzeda�owe (SALES, sal_prd_id) z
--podzapytaniem, w kt�rych dla danych produktowych uwzgl�dnij tylko te produkty
--(PRODUCTS, id), kt�rych ilo�� jednostek jest wi�ksza od 5 (product_quantity).

--W wynikach wy�wietl unikatow� nazw� produktu (product_name) oraz z��czeniem
--ROK_MIESI�C z danych sprzeda�owych - data sprzeda�y.

--Dane posortuj wed�ug pierwszej kolumny malej�co.

SELECT
	DISTINCT p.product_name,
	concat(EXTRACT(YEAR FROM s.sal_date), '/', EXTRACT(MONTH FROM s.sal_date)) AS year_month
FROM
	modul7.sales AS s
RIGHT JOIN (
	SELECT
		pr.id, pr.product_name
	FROM
		modul7.products AS pr
	WHERE
		pr.product_quantity > 5) AS p ON
	s.sal_prd_id = p.id
ORDER BY
	p.product_name DESC;


--Modu� 7 - Zadanie 5
--Dodaj nowy region do tabeli PRODUCT_MANUFACTURED_REGION. 
--Nast�pnie korzystaj�c z konstrukcji FULL JOIN po��cz dane o produktach
--(PRODUCTS,product_man_region) z danymi o regionach produkt�w w kt�rych
--zosta�y one stworzone (PRODUCT_MANUFACTURED_REGION, id)
--Wy�wietl w wynikach wszystkie atrybuty z obu tabel.

INSERT
	INTO
	modul7.product_manufactured_region (region_name, region_code, established_year)
VALUES ('South America', NULL, 2020);
      
SELECT
	pr.*,
	pmr.*
FROM
	modul7.products AS pr
FULL JOIN modul7.product_manufactured_region pmr ON
	pr.product_man_region = pmr.id;
   

--Modu� 7 - Zadanie 6
--Uzyskaj te same wyniki, co w zadaniu 5 dla stworzonego zapytania, tym razem nie
--korzystaj ze sk�adni FULL JOIN. Wykorzystaj INNER JOIN / LEFT / RIGHT JOIN lub
--inne cz�ci SQL-a, kt�re znasz :)

SELECT
	pr.*,
	pmr.*
FROM
	modul7.products AS pr
LEFT JOIN modul7.product_manufactured_region pmr ON
	pr.product_man_region = pmr.id
UNION
SELECT
	pr.*,
	pmr.*
FROM
	modul7.products AS pr
RIGHT JOIN modul7.product_manufactured_region pmr ON
	pr.product_man_region = pmr.id;
      

--Modu� 7 - Zadanie 7
--Wykorzystaj konstrukcj� WITH i zmie� Twoje zapytanie z zadania 4 w taki spos�b, aby
--podzapytanie znalaz�o si� w sekcji CTE (common table expression = WITH) zapytania.

WITH quantity_5 AS (
SELECT
	pr.id,
	pr.product_name
FROM
	modul7.products AS pr
WHERE
	pr.product_quantity > 5)
SELECT
	DISTINCT p.product_name,
	concat(EXTRACT(YEAR FROM s.sal_date), '/', EXTRACT(MONTH FROM s.sal_date)) AS year_month
FROM
	modul7.sales AS s
RIGHT JOIN quantity_5 AS p ON
	s.sal_prd_id = p.id
ORDER BY
	p.product_name DESC;
      

--Modu� 7 - Zadanie 8
--Usu� wszystkie te produkty (PRODUCTS), kt�re s� przypisane do regionu EMEA i kodu E_EMEA.
--Skorzystaj z konstrukcji USING lub EXISTS.

DELETE
FROM
	modul7.products AS pr
WHERE
	EXISTS (
	SELECT
		*
	FROM
		modul7.products AS pr1
	JOIN modul7.product_manufactured_region AS pmr ON
		pr1.product_man_region = pmr.id
	WHERE
		pr1.id = pr.id
		AND 
		pmr.region_name = 'EMEA'
		AND pmr.region_code = 'E_EMEA') RETURNING *;
     

--Modu� 7 - Zadanie 9
--OPCJONALNE: Korzystaj�c z konstrukcji WITH RECURSIVE stw�rz ci�g Fibonacciego,
--kt�rego wyniki b�d� ograniczone do warto�ci poni�ej 100.

-- F0 = 0 and F1 = 1.
-- Fn = Fn-1 + Fn-2
	
WITH RECURSIVE fibonacci_function(n, fibonacci, m) AS (
		VALUES (0, 0, 1)
	UNION ALL
		SELECT n + 1, m, m + fibonacci
			FROM fibonacci_function
			WHERE fibonacci < 100 
			)
	SELECT n, fibonacci AS "F(n)"
		FROM fibonacci_function
	WHERE fibonacci < 100;


