/*********************************************************************************************************************************/
/************************************************************* MODUL 5 ***********************************************************/
/*********************************************************************************************************************************/

--Modu� 5 - Zadanie 1 
--Utw�rz nowy schemat dml_exercises

DROP SCHEMA IF EXISTS dml_exercises CASCADE;

CREATE SCHEMA dml_exercises;

--Modu� 3 - Zadanie 2 
--Utw�rz now� tabel� sales w schemacie dml_exercises wed�ug opisu:
	--Tabela: sales;
	--Kolumny:
		--id - typ SERIAL, klucz g��wny,
		--sales_date - typ data i czas (data + cz�� godziny, minuty, sekundy), to pole ma niezawiera� warto�ci nieokre�lonych NULL,
		--sales_amount - typ zmiennoprzecinkowy (NUMERIC 38 znak�w, do 2 znak�w po przecinku)
		--sales_qty - typ zmiennoprzecinkowy (NUMERIC 10 znak�w, do 2 znak�w po przecinku)
		--added_by - typ tekstowy (nielimitowana ilo�� znak�w), z warto�ci� domy�ln� 'admin'
		--korzystaj�c z definiowania przy tworzeniu tabeli, po definicji kolumn, dodaje 
		--ograniczenie o nazwie sales_less_1k na polu sales_amount typu CHECK takie, �e
		--warto�ci w polu sales_amount musz� by� mniejsze lub r�wne 1000

DROP TABLE IF EXISTS dml_exercises.sales;

CREATE TABLE IF NOT EXISTS dml_exercises.sales (
		id SERIAL,
		sales_dates TIMESTAMP NOT NULL,
		sales_amount NUMERIC(38,2),
		sales_qty NUMERIC(10,2),
		added_by TEXT DEFAULT 'admin',
		CONSTRAINT sales_less_1k CHECK (sales_amount <= 1000),
		CONSTRAINT pk_sales PRIMARY KEY (id)
);
		
--SELECT * FROM dml_exercises.sales;

--Modu� 3 - Zadanie 3 
--3. Dodaj to tabeli kilka wierszy korzystaj�c ze sk�adni INSERT INTO
--3.1 Tak, aby id by�o generowane przez sekwencj�
--3.2 Tak by pod pole added_by wpisa� warto�� nieokre�lon� NULL
--3.3 Tak, aby sprawdzi� zachowanie ograniczenia sales_less_1k, gdy wpiszemy warto�ci wi�ksze od 1000

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES ('1999-01-08 04:05:06', 999.99, 10, NULL); --wstawia warto�� NULL w added_by

--SELECT * FROM dml_exercises.sales;
--DELETE FROM dml_exercises.sales;
--TRUNCATE dml_exercises.sales RESTART IDENTITY;

--INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty) VALUES ('1999-01-08 12:05:10', 1999.99, 12); --b��d przez ograniczenie

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty) 
	VALUES ('1999-01-08 12:05:10', 100.99, 12); --wstawia warto�� domy�ln� 'admin' w added_by

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES ('2020-01-08 14:00:00', 950.00, 15, ''); --zostawia puste pole w added_by

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES 
	('2020-08-08 18:00:00', 280.00, 100, 'postgres'),
	('2020-10-05 12:00:00', 350.00, 150, 'postgres');

--Modu� 3 - Zadanie 4 
--Co zostanie wstawione, jako format godzina (HH), minuta (MM), sekunda (SS), w polu
--sales_date, jak wstawimy do tabeli nast�puj�cy rekord?

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('20/11/2019', 101, 50, NULL);

--SQL Error [22008]: ERROR: date/time field value out of range: "20/11/2019" Hint: Perhaps you need a different "datestyle" setting.

--SHOW datestyle; -- zwr�ci�o "ISO, MDY"

--zatem poprawne zapytanie b�dzie wygl�da�o nast�pujaco:

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('11/20/2019', 101, 50, NULL);

--jako format godzina (HH), minuta (MM), sekunda (SS) wstawione zostanie 00:00:00
--SELECT * FROM dml_exercises.sales;

--Modu� 3 - Zadanie 5 
--Jaka b�dzie warto�� w atrybucie sales_date, po wstawieniu wiersza jak poni�ej. 
--Jak zintepretujesz miesi�c i dzie�, �eby mie� pewno��, o jaki konkretnie chodzi.

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('04/04/2020', 101, 50, NULL);

--sales_dates b�dzie mialo warto�� "2020-04-04 00:00:00"

--SHOW datestyle;

--SELECT * FROM dml_exercises.sales;

--Modu� 3 - Zadanie 6 
--Do tabeli sales wstaw wiersze korzystaj�c z poni�szego polecenia
	--INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by)
	--SELECT NOW() + (random() * (interval '90 days')) + '30 days',
	--random() * 500 + 1,
	--random() * 100 + 1,
	--NULL
	--FROM generate_series(1, 20000) s(i);

INSERT
	INTO
	dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by)
SELECT
	NOW() + (random() * (INTERVAL '90 days')) + '30 days',
	random() * 500 + 1,
	random() * 100 + 1,
	NULL
FROM
	generate_series(1, 20000) s(i);
 
--SELECT * FROM dml_exercises.sales;

--DELETE FROM dml_exercises.sales;

--Modu� 3 - Zadanie 7 
--Korzystaj�c ze sk�adni UPDATE, zaktualizuj atrybut added_by, wpisuj�c mu warto��
--'sales_over_200', gdy warto�� sprzeda�y (sales_amount jest wi�ksza lub r�wna 200)

UPDATE
	dml_exercises.sales
SET
	added_by = 'sales_over_200'
WHERE
	sales_amount >= 200;

--SELECT * FROM dml_exercises.sales;

--SELECT * FROM dml_exercises.sales WHERE sales_amount >= 200; --aktualizacja zadzia�a�a poprawnie

--Modu� 3 - Zadanie 8 
--Korzystaj�c ze sk�adni DELETE, usu� te wiersze z tabeli sales, dla kt�rych warto�� w polu
--added_by jest warto�ci� nieokre�lon� NULL. Sprawd� r�nic� mi�dzy zapisem added_by = NULL, a added_by IS NULL

DELETE FROM dml_exercises.sales 
	WHERE added_by = NULL; -- brak efekt�w usuwania

/*SELECT * FROM dml_exercises.sales 
	WHERE sales_amount < 200;

SELECT COUNT(*) FROM dml_exercises.sales;
*/
	
DELETE FROM dml_exercises.sales 
	WHERE added_by IS NULL; --rekordy, gdzie added_by jest warto�ci� NULL usuni�to poprawnie

/*
SELECT * FROM dml_exercises.sales WHERE sales_amount < 200;

SELECT COUNT(*) FROM dml_exercises.sales;
*/

--Modu� 3 - Zadanie 9 
--Wyczy�� wszystkie dane z tabeli sales i zrestartuj sekwencje

TRUNCATE TABLE dml_exercises.sales RESTART IDENTITY;

--SELECT COUNT(*) FROM dml_exercises.sales;

--Modu� 3 - Zadanie 10 - W tym zadaniu skorzysta�am z zadania 6, a nie 4 zeby mie� wi�cej rekord�w
--DODATKOWE ponownie wstaw do tabeli sales wiersze jak w zadaniu 4.
--Utw�rz kopi� zapasow� tabeli do pliku. Nast�pnie usu� tabel� ze schematu dml_exercises i
--odtw�rz j� z kopii zapasowej.

/*
INSERT
	INTO
	dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by)
SELECT
	NOW() + (random() * (INTERVAL '90 days')) + '30 days',
	random() * 500 + 1,
	random() * 100 + 1,
	NULL
FROM
	generate_series(1, 20000) s(i);

*/

--SELECT * FROM dml_exercises.sales;

--SELECT COUNT(*) FROM dml_exercises.sales;

/********************Polecenia z konsoli****************************/

--cd C:\Users\olasa\AppData\Roaming\DBeaverData\drivers\clients\postgresql\win\13>
/*
pg_dump --host localhost ^
        --port 5435 ^
        --username postgres ^
        --format d ^
        --file "C:\Users\olasa\AppData\Roaming\DBeaverData\workspace6\ZrozumSQL_ZadaniaDomowe\Zadania_domowe_OlaS\backup" ^
        --table dml_exercises.sales ^
        postgres

pg_dump --host localhost ^
        --port 5435 ^
        --username postgres ^
        --format plain ^
        --file "C:\Users\olasa\AppData\Roaming\DBeaverData\workspace6\ZrozumSQL_ZadaniaDomowe\Zadania_domowe_OlaS\backup\dml_exercises.sales_bp.sql" ^
        --table dml_exercises.sales ^
        postgres

pg_restore --host localhost ^
           --port 5435 ^
           --username postgres ^
           --dbname postgres ^
           --clean ^
           "C:\Users\olasa\AppData\Roaming\DBeaverData\workspace6\ZrozumSQL_ZadaniaDomowe\Zadania_domowe_OlaS\backup"  


psql -U postgres -p 5435 -h localhost -d postgres -f "C:\Users\olasa\AppData\Roaming\DBeaverData\workspace6\ZrozumSQL_ZadaniaDomowe\Zadania_domowe_OlaS\backup\dml_exercises.sales_bp.sql"
*/