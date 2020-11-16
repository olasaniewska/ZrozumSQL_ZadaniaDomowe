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
  
      
--Modu³ 7 - Zadanie 1
--Korzystaj¹c z konstrukcji INNER JOIN po³¹cz dane sprzeda¿owe (SALES, sal_prd_id) z
--danymi o produktach (PRODUCTS, id). W wynikach poka¿ tylko te produkty, które
--powsta³y w regionie EMEA. Wyniki ogranicz do 100 wierszy.

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
     

--Modu³ 7 - Zadanie 2
--Korzystaj¹c z konstrukcji LEFT JOIN po³¹cz dane o produktach (PRODUCTS,
--product_man_region) z danymi o regionach w których produkty powsta³y
--(PRODUCT_MANUFACTURED_REGION, id) 

--W wynikach wyœwietl wszystkie atrybuty z tabeli produktów i atrybut REGION_NAME
--z tabeli PRODUCT_MANUFACTURED_REGION. Dodatkowo w trakcie z³¹czenia
--ogranicz dane brane przy z³¹czenia do tych regionów, które zosta³y za³o¿one po 2012 roku.

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
      

--Modu³ 7 - Zadanie 3
--Korzystaj¹c z konstrukcji LEFT JOIN po³¹cz dane o produktach (PRODUCTS,
--product_man_region) z danymi o regionach w których produkty powsta³y
--(PRODUCT_MANUFACTURED_REGION, id). 

--W wynikach wyœwietl wszystkie atrybuty z tabeli produktów i atrybut REGION_NAME
--z tabeli PRODUCT_MANUFACTURED_REGION.       
      
--Dodatkowo wyfiltruj dane wynikowe taki sposób, aby pokazaæ tylko te produkty, dla
--których regiony, w których powsta³y zosta³y za³o¿one po 2012 roku.
--Porównaj te wyniki z wynikami z zadania 2.

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
   
/* W zadaniu drugim (gdzie w trakcie z³¹czenia ograniczono dane) zwrócone zosta³y dane dla których regiony zosta³y za³o¿one po 2012 roku oraz te dane, których daty za³o¿enia regionu nie by³y podane (NULL)
 * W zadaniu trzecim zwrócone zosta³y dane dla których regiony zosta³y za³o¿one tylko i wy³¹cznie po 2012 roku
 */


--Modu³ 7 - Zadanie 4
--Korzystaj¹c z konstrukcji RIGHT JOIN po³¹cz dane sprzeda¿owe (SALES, sal_prd_id) z
--podzapytaniem, w których dla danych produktowych uwzglêdnij tylko te produkty
--(PRODUCTS, id), których iloœæ jednostek jest wiêksza od 5 (product_quantity).

--W wynikach wyœwietl unikatow¹ nazwê produktu (product_name) oraz z³¹czeniem
--ROK_MIESI¥C z danych sprzeda¿owych - data sprzeda¿y.

--Dane posortuj wed³ug pierwszej kolumny malej¹co.

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


--Modu³ 7 - Zadanie 5
--Dodaj nowy region do tabeli PRODUCT_MANUFACTURED_REGION. 
--Nastêpnie korzystaj¹c z konstrukcji FULL JOIN po³¹cz dane o produktach
--(PRODUCTS,product_man_region) z danymi o regionach produktów w których
--zosta³y one stworzone (PRODUCT_MANUFACTURED_REGION, id)
--Wyœwietl w wynikach wszystkie atrybuty z obu tabel.

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
   

--Modu³ 7 - Zadanie 6
--Uzyskaj te same wyniki, co w zadaniu 5 dla stworzonego zapytania, tym razem nie
--korzystaj ze sk³adni FULL JOIN. Wykorzystaj INNER JOIN / LEFT / RIGHT JOIN lub
--inne czêœci SQL-a, które znasz :)

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
      

--Modu³ 7 - Zadanie 7
--Wykorzystaj konstrukcjê WITH i zmieñ Twoje zapytanie z zadania 4 w taki sposób, aby
--podzapytanie znalaz³o siê w sekcji CTE (common table expression = WITH) zapytania.

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
      

--Modu³ 7 - Zadanie 8
--Usuñ wszystkie te produkty (PRODUCTS), które s¹ przypisane do regionu EMEA i kodu E_EMEA.
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
     

--Modu³ 7 - Zadanie 9
--OPCJONALNE: Korzystaj¹c z konstrukcji WITH RECURSIVE stwórz ci¹g Fibonacciego,
--którego wyniki bêd¹ ograniczone do wartoœci poni¿ej 100.

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


