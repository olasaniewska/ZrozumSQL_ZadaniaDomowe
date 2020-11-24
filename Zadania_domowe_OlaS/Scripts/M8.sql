/*********************************************************************************************************************************/
/************************************************************* MODUL 8 ***********************************************************/
/*********************************************************************************************************************************/

DROP SCHEMA IF EXISTS modul8 CASCADE;

CREATE SCHEMA modul8;

DROP TABLE IF EXISTS modul8.products, modul8.sales, modul8.product_manufactured_region CASCADE;

CREATE TABLE modul8.products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),	
	manufactured_date DATE,
	product_man_region INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE modul8.sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE modul8.product_manufactured_region (
	id SERIAL,
	region_name VARCHAR(25),
	region_code VARCHAR(10),
	established_year INTEGER
);

INSERT INTO modul8.product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('EMEA', 'E_EMEA', 2010),
	  		 ('EMEA', 'W_EMEA', 2012),
	  		 ('APAC', NULL, 2019),
	  		 ('North America', NULL, 2012),
	  		 ('Africa', NULL, 2012);

INSERT INTO modul8.products (product_name, product_code, product_quantity, manufactured_date, product_man_region)
     SELECT 'Product '||floor(random() * 10 + 1)::int,
            'PRD'||floor(random() * 10 + 1)::int,
            random() * 10 + 1,
            CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date),
            CEIL(random()*(10-5))::int
       FROM generate_series(1, 10) s(i);  
      
INSERT INTO modul8.sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 10000) s(i);     
       
      
--Modu³ 8 - Zadanie 1    
--Oblicz œredni¹ iloœæ jednostek produktów (PRODUCTS) w podziale na regiony z tabeli
--PRODUCT_MANUFACTURED_REGION (atrybut region_name). W wynikach wyœwietl
--tylko nazwê regionu (REGION_NAME) i obliczon¹ œredni¹. Dane posortuj wed³ug
--œredniej malej¹co.

SELECT
	pmr.region_name,
	round (COALESCE(avg(p.product_quantity), 0), 2) AS average_quantity
FROM
	modul8.products AS p
RIGHT JOIN modul8.product_manufactured_region pmr ON
	p.product_man_region = pmr.id
GROUP BY
	pmr.region_name
ORDER BY
	average_quantity DESC;


--Modu³ 8 - Zadanie 2      
--Korzystaj¹c z funkcji STRING_AGG, dla ka¿dej nazwy regionu z tabeli
--PRODUCT_MANUFACTURED_REGION stwórz listê nazw produktów (product_name)
--w tych regionach. SprawdŸ czy wewn¹trz funkcji STRING_AGG mo¿esz u¿yæ ORDER
--BY i jak ewentualnie to wp³ynie na wyniki?

--order by dzia³a prawid³owo w obrêbie grup

SELECT
	pmr.region_name,
	string_agg(DISTINCT p.product_name, ', ' ORDER BY p.product_name ASC) products
FROM
	modul8.product_manufactured_region pmr
LEFT JOIN modul8.products p ON
	pmr.id = p.product_man_region
GROUP BY
	pmr.region_name
ORDER BY
	pmr.region_name ASC;


--Modu³ 8 - Zadanie 3      
--Wyœwietl iloœæ sprzedanych produktów COUNT(s.sal_prd_id), które wziê³y udzia³ w
--transakcjach sprzeda¿owych, filtruj¹c dane jedynie do regionu EMEA, wed³ug tabeli
--PRODUCT_MANUFACTURED_REGION. W danych wynikowych powinien siê znaleŸæ
--region (REGION_NAME), nazwa produktu (PRODUCT_NAME) oraz ca³kowita liczba z
--danych sprzeda¿owych.

SELECT
	pmr.region_name,
	p.product_name,
	COUNT(s.sal_prd_id) AS quantity_per_product,
	(
	SELECT
		COUNT(s1.sal_prd_id)
	FROM
		modul8.sales AS s1
	INNER JOIN modul8.products AS p1 ON
		s1.sal_prd_id = p1.id
	INNER JOIN modul8.product_manufactured_region AS pmr1 ON
		p1.product_man_region = pmr1.id
		AND pmr1.region_name = 'EMEA'
	GROUP BY
		pmr1.region_name) AS full_quantity
FROM
	modul8.sales AS s
INNER JOIN modul8.products AS p ON
	s.sal_prd_id = p.id
INNER JOIN modul8.product_manufactured_region AS pmr ON
	p.product_man_region = pmr.id
	AND pmr.region_name = 'EMEA'
GROUP BY
	pmr.region_name,
	p.product_name;


--Modu³ 8 - Zadanie 4
--Wyœwietl sumê sprzeda¿y na podstawie danych sprzeda¿owych (SALES) w podziale na
--nowy atrybut ROK_MIESIAC stworzony na podstawie kolumny SAL_DATE. Dane
--wynikowe posortuj od najwiêkszej do najmniejszej sprzeda¿y.

SELECT
	(EXTRACT(YEAR
FROM
	s.sal_date)|| '/' || EXTRACT(MONTH
FROM
	s.sal_date)) AS year_month,
	sum(s.sal_value) AS sum_sal_value
FROM
	modul8.sales AS s
GROUP BY
	year_month
ORDER BY
	sum_sal_value DESC;


--Modu³ 8 - Zadanie 5
--Korzystaj¹c z konstrukcji GROUPING SETS oblicz œredni¹ iloœæ jednostek produktów w
--grupach - kod produktu (PRODUCT_CODE), rok produkcji (na podstawie atrybutu
--MANUFACTURED_DATE) oraz regionu produkcji (REGION_NAME z tabeli
--PRODUCT_MANUFACTURED_REGION). Do danych wynikowych do³ó¿ kolumnê z
--grup¹ rekordów korzystaj¹c ze sk³adni GROUPING.

SELECT
	p.product_code,
	EXTRACT(YEAR
FROM
	p.manufactured_date),
	pmr.region_name,
	GROUPING (p.product_code ,
	EXTRACT(YEAR
FROM
	p.manufactured_date),
	pmr.region_name),
	avg(p.product_quantity)
FROM
	modul8.products p
LEFT JOIN modul8.product_manufactured_region pmr ON
	p.product_man_region = pmr.id
GROUP BY
	GROUPING SETS ((p.product_code) ,
	(EXTRACT(YEAR
FROM
	p.manufactured_date)),
	(pmr.region_name),
	());


--Modu³ 8 - Zadanie 6
--Dla ka¿dego PRODUCT_NAME oblicz sumê iloœci jednostek w podziale na region_name
--z tabeli PRODUCT_MANUFACTURED_REGION. Skorzystaj z funkcji okna.
--W wynikach wyœwietl: PRODUCT_NAME, PRODUCT_CODE,
--MANUFACTURED_DATE, PRODUCT_MAN_REGION, REGION_NAME i obliczon¹
--sumê.

SELECT
	p.product_name,
	p.product_code,
	p.manufactured_date ,
	p.product_man_region ,
	pmr.region_name,
	sum(p.product_quantity) OVER (PARTITION BY pmr.region_name) sum_per_region
FROM
	modul8.products p
LEFT JOIN modul8.product_manufactured_region pmr ON
	p.product_man_region = pmr.id
ORDER BY
	p.product_name ASC;


--Modu³ 8 - Zadanie 7
--Na podstawie zapytania i wyników z zadania 6. Stwórz ranking wed³ug posiadanej iloœci
--produktów od najwiêkszej do najmniejszej, w taki sposób, aby w rankingu nie by³o
--brakuj¹cych elementów (liczb). W wyniku wyœwietl te produkty, których iloœæ jest 2
--najwiêksz¹ iloœci¹. Atrybuty do wyœwietlenia, PRODUCT_NAME, REGION_NAME,
--suma iloœci per region (obliczona w zadaniu 6).

SELECT
	main.*
FROM
	(
	SELECT
		sum_per_region_1.*, DENSE_RANK () OVER (
		ORDER BY sum_per_region_1.sum_per_region) dens
	FROM
		(
		SELECT
			p.product_name AS pr_name, pmr.region_name AS reg_name, sum(p.product_quantity) OVER (PARTITION BY pmr.region_name) sum_per_region
		FROM
			modul8.products p
		LEFT JOIN modul8.product_manufactured_region pmr ON
			p.product_man_region = pmr.id ) sum_per_region_1) main
WHERE
	main.dens = 2
ORDER BY
	main.pr_name ASC;
