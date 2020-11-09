/*********************************************************************************************************************************/
/************************************************************* MODUL 6 ***********************************************************/
/*********************************************************************************************************************************/

--Modu³ 6
--Przygotowanie - korzystaj¹c ze skryptu poni¿ej utwórz obiekty potrzebne do zadania

DROP TABLE IF EXISTS products;

CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);


INSERT
	INTO
	products (product_name, product_code, product_quantity, manufactured_date)
SELECT
	'Product ' || floor(random() * 10 + 1)::int,
	'PRD' || floor(random() * 10 + 1)::int,
	random() * 10 + 1,
	CAST((NOW() - (random() * (INTERVAL '90 days')))::timestamp AS date)
FROM
	generate_series(1,
	10) s(i);



DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_qty NUMERIC(10,2),
	sal_product_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);


INSERT
	INTO
	sales (sal_description, sal_date, sal_value, sal_qty, sal_product_id)
SELECT
	LEFT(md5(i::text),
	15),
	CAST((NOW() - (random() * (INTERVAL '60 days'))) AS DATE),
	random() * 100 + 1,
	floor(random() * 10 + 1)::int,
	floor(random() * 10)::int
FROM
	generate_series(1,
	10000) s(i);
	

--Modu³ 6 - Zadanie 1 
--Wyœwietl unikatowe daty stworzenia produktów (wed³ug atrybutu manufactured_date)

SELECT
	DISTINCT p.manufactured_date
FROM
	products p;


--Modu³ 6 - Zadanie 2
--Jak sprawdzisz czy 10 wstawionych produktów to 10 unikatowych kodów produktów?

SELECT
	product_code,
	count(p.product_code) AS quantity_of_this_product_code
FROM
	dml_exercises.products p
GROUP BY
	product_code
ORDER BY
	product_code ASC;

--Modu³ 6 - Zadanie 3 
--Korzystaj¹c ze sk³adni IN wyœwietl produkty od kodach PRD1 i PRD9

SELECT
	p.*
FROM
	products p
WHERE
	p.product_code IN ('PRD1','PRD9');

--Modu³ 6 - Zadanie 4
--Wyœwietl wszystkie atrybuty z danych sprzeda¿owych, takie ¿e data sprzeda¿y jest w
--zakresie od 1 sierpnia 2020 do 31 sierpnia 2020 (w³¹cznie). Dane wynikowe maj¹ byæ
--posortowane wed³ug wartoœci sprzeda¿y malej¹co i daty sprzeda¿y rosn¹co.

SELECT
	s.*
FROM
	sales s
WHERE
	s.sal_date BETWEEN '2020-08-01' AND '2020-08-31'
ORDER BY
	s.sal_value DESC,
	s.sal_date ASC;

--Modu³ 6 - Zadanie 5
--Korzystaj¹c ze sk³adni NOT EXISTS wyœwietl te produkty z tabeli PRODUCTS, które nie
--bior¹ udzia³u w transakcjach sprzeda¿owych (tabela SALES). ID z tabeli Products i
--SAL_PRODUCT_ID to klucz ³¹czenia.

SELECT
	p.*
FROM
	products p
WHERE
	NOT EXISTS (
					SELECT
						s.sal_product_id
					FROM
						sales s
					WHERE
						s.sal_product_id = p.id);

	/*
SELECT
	s.sal_product_id,
	count(*) AS quantity
FROM
	dml_exercises.sales s
GROUP BY
	s.sal_product_id
ORDER BY
	s.sal_product_id DESC;
	
*/
	
--Modu³ 6 - Zadanie 6 
--Korzystaj¹c ze sk³adni ANY i operatora = wyœwietl te produkty, których wystêpuj¹ w
--transakcjach sprzeda¿owych (wed³ug klucza Products ID, Sales SAL_PRODUCT_ID)
--takich, ¿e wartoœæ sprzeda¿y w transakcji jest wiêksza od 100.

SELECT
	p.*
FROM
	products p
WHERE
	p.id = ANY (
					SELECT
						s.sal_product_id 
					FROM
						sales s
					WHERE
						s.sal_value > 100);
	
--Modu³ 6 - Zadanie 7 
--Stwórz now¹ tabelê PRODUCTS_OLD_WAREHOUSE o takich samych kolumnach jak
--istniej¹ca tabela produktów (tabela PRODUCTS). Wstaw do nowej tabeli kilka wierszy -
--dowolnych wed³ug Twojego uznania. 

DROP TABLE IF EXISTS products_old_warehouse;

CREATE TABLE products_old_warehouse (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

INSERT
	INTO
	PRODUCTS_OLD_WAREHOUSE(product_name, product_code, product_quantity, manufactured_date)
VALUES( 'Product 7', 'PRD7', 9.16, '2020-08-31'),
( 'Product 2', 'PRD4', 19.80, '2020-10-23'),
( 'Product 1', 'PRD1', 5.80, '2020-05-05'),
( 'Product 10', 'PRD10', 15.10, '2020-05-15'),
( 'Product 11', 'PRD11', 2.30, '2020-01-18'),
( 'Product 5', 'PRD6', 7.35, '2020-03-04'),
( 'Product 4', 'PRD4', 8.30, '2020-02-07');

--Modu³ 6 - Zadanie 8
--Na podstawie tabeli z zadania 7, korzystaj¹c z operacji UNION oraz UNION ALL po³¹cz
--tabelê PRODUCTS_OLD_WAREHOUSE z 5 dowolnym produktami z tabeli
--PRODUCTS, w wyniku wyœwietl jedynie nazwê produktu (kolumna PRODUCT_NAME)
--i kod produktu (kolumna PRODUCT_CODE). Czy w przypadku wykorzystania UNION
--jakieœ wierszy zosta³y pominiête? 

SELECT
	pr.product_name,
	pr.product_code
FROM
	products_old_warehouse pr
UNION
SELECT
	p1.product_name,
	p1.product_code
FROM
	(
	SELECT
		p.product_name, p.product_code
	FROM
		products p
	ORDER BY
		p.product_name ASC
	LIMIT(5)) p1
ORDER BY
	product_name ASC;

--W przypadku UNION zosta³y pominiête wiersze, które s¹ duplikatami

SELECT
	pr.product_name,
pr.product_code
FROM
	products_old_warehouse pr
UNION ALL
SELECT
	p1.product_name,
	p1.product_code
FROM
	(
	SELECT
		p.product_name, p.product_code
	FROM
		products p
	ORDER BY
		p.product_name ASC
	LIMIT(5)) p1
ORDER BY
	product_name;

--Modu³ 6 - Zadanie 9
--Na podstawie tabeli z zadania 7, korzystaj¹c z operacji EXCEPT znajdŸ ró¿nicê zbiorów
--pomiêdzy tabel¹ PRODUCTS_OLD_WAREHOUSE a PRODUCTS, w wyniku wyœwietl
--jedynie kod produktu (kolumna PRODUCT_CODE). 

SELECT
	pr.product_code
FROM
	products_old_warehouse pr
EXCEPT
SELECT
	p.product_code
FROM
	products p
ORDER BY
	product_code ASC;

--Modu³ 6 - Zadanie 10 
--Wyœwietl 10 rekordów z tabeli sprzeda¿owej sales. Dane powinny byæ posortowane
--wed³ug wartoœci sprzeda¿y (kolumn SAL_VALUE) malej¹co.

SELECT
	s.*
FROM
	sales s
ORDER BY
	s.sal_value DESC
LIMIT (10);

--Modu³ 6 - Zadanie 11 
--Korzystaj¹c z funkcji SUBSTRING na atrybucie SAL_DESCRIPTION, wyœwietl 3 dowolne
--wiersze z tabeli sprzeda¿owej w taki sposób, aby w kolumnie wynikowej dla
--SUBSTRING z SAL_DESCRIPTION wyœwietlonych zosta³o tylko 3 pierwsze znaki.

--3 dowolne wiersze, wiêc trochê urozmaici³am zapytanie

SELECT
	SUBSTRING(s.sal_description, 1, 3) AS short_sal_description,
	s.*
FROM
	sales s
WHERE
	s.sal_description LIKE '%a'
ORDER BY
	short_sal_description DESC,
	s.id ASC
LIMIT 3 OFFSET 5;

--Modu³ 6 - Zadanie 12
--Korzystaj¹c ze sk³adni LIKE znajdŸ wszystkie dane sprzeda¿owe, których opis sprzeda¿y
--(SAL_DESCRIPTION) zaczyna siê od c4c.

SELECT
	s.*
FROM
	sales s
WHERE
	s.sal_description LIKE 'c4c%';