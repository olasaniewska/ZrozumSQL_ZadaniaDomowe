/*********************************************************************************************************************************/
/************************************************************* MODUL 5 ***********************************************************/
/*********************************************************************************************************************************/

--Modu³ 5 - Zadanie 1 
--Utwórz nowy schemat dml_exercises

DROP SCHEMA IF EXISTS dml_exercises CASCADE;

CREATE SCHEMA dml_exercises;

--Modu³ 3 - Zadanie 2 
--Utwórz now¹ tabelê sales w schemacie dml_exercises wed³ug opisu:
	--Tabela: sales;
	--Kolumny:
		--id - typ SERIAL, klucz g³ówny,
		--sales_date - typ data i czas (data + czêœæ godziny, minuty, sekundy), to pole ma niezawieraæ wartoœci nieokreœlonych NULL,
		--sales_amount - typ zmiennoprzecinkowy (NUMERIC 38 znaków, do 2 znaków po przecinku)
		--sales_qty - typ zmiennoprzecinkowy (NUMERIC 10 znaków, do 2 znaków po przecinku)
		--added_by - typ tekstowy (nielimitowana iloœæ znaków), z wartoœci¹ domyœln¹ 'admin'
		--korzystaj¹c z definiowania przy tworzeniu tabeli, po definicji kolumn, dodaje 
		--ograniczenie o nazwie sales_less_1k na polu sales_amount typu CHECK takie, ¿e
		--wartoœci w polu sales_amount musz¹ byæ mniejsze lub równe 1000

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

--Modu³ 3 - Zadanie 3 
--3. Dodaj to tabeli kilka wierszy korzystaj¹c ze sk³adni INSERT INTO
--3.1 Tak, aby id by³o generowane przez sekwencjê
--3.2 Tak by pod pole added_by wpisaæ wartoœæ nieokreœlon¹ NULL
--3.3 Tak, aby sprawdziæ zachowanie ograniczenia sales_less_1k, gdy wpiszemy wartoœci wiêksze od 1000

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES ('1999-01-08 04:05:06', 999.99, 10, NULL); --wstawia wartoœæ NULL w added_by

--SELECT * FROM dml_exercises.sales;
--DELETE FROM dml_exercises.sales;
--TRUNCATE dml_exercises.sales RESTART IDENTITY;

--INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty) VALUES ('1999-01-08 12:05:10', 1999.99, 12); --b³¹d przez ograniczenie

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty) 
	VALUES ('1999-01-08 12:05:10', 100.99, 12); --wstawia wartoœæ domyœln¹ 'admin' w added_by

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES ('2020-01-08 14:00:00', 950.00, 15, ''); --zostawia puste pole w added_by

INSERT INTO dml_exercises.sales (sales_dates, sales_amount, sales_qty, added_by) 
	VALUES 
	('2020-08-08 18:00:00', 280.00, 100, 'postgres'),
	('2020-10-05 12:00:00', 350.00, 150, 'postgres');

--Modu³ 3 - Zadanie 4 
--Co zostanie wstawione, jako format godzina (HH), minuta (MM), sekunda (SS), w polu
--sales_date, jak wstawimy do tabeli nastêpuj¹cy rekord?

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('20/11/2019', 101, 50, NULL);

--SQL Error [22008]: ERROR: date/time field value out of range: "20/11/2019" Hint: Perhaps you need a different "datestyle" setting.

--SHOW datestyle; -- zwróci³o "ISO, MDY"

--zatem poprawne zapytanie bêdzie wygl¹da³o nastêpujaco:

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('11/20/2019', 101, 50, NULL);

--jako format godzina (HH), minuta (MM), sekunda (SS) wstawione zostanie 00:00:00
--SELECT * FROM dml_exercises.sales;

--Modu³ 3 - Zadanie 5 
--Jaka bêdzie wartoœæ w atrybucie sales_date, po wstawieniu wiersza jak poni¿ej. 
--Jak zintepretujesz miesi¹c i dzieñ, ¿eby mieæ pewnoœæ, o jaki konkretnie chodzi.

INSERT INTO dml_exercises.sales (sales_dates, sales_amount,sales_qty, added_by)
	VALUES ('04/04/2020', 101, 50, NULL);

--sales_dates bêdzie mialo wartoœæ "2020-04-04 00:00:00"

--SHOW datestyle;

--SELECT * FROM dml_exercises.sales;

--Modu³ 3 - Zadanie 6 
--Do tabeli sales wstaw wiersze korzystaj¹c z poni¿szego polecenia
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

--Modu³ 3 - Zadanie 7 
--Korzystaj¹c ze sk³adni UPDATE, zaktualizuj atrybut added_by, wpisuj¹c mu wartoœæ
--'sales_over_200', gdy wartoœæ sprzeda¿y (sales_amount jest wiêksza lub równa 200)

UPDATE
	dml_exercises.sales
SET
	added_by = 'sales_over_200'
WHERE
	sales_amount >= 200;

--SELECT * FROM dml_exercises.sales;

--SELECT * FROM dml_exercises.sales WHERE sales_amount >= 200; --aktualizacja zadzia³a³a poprawnie

--Modu³ 3 - Zadanie 8 
--Korzystaj¹c ze sk³adni DELETE, usuñ te wiersze z tabeli sales, dla których wartoœæ w polu
--added_by jest wartoœci¹ nieokreœlon¹ NULL. SprawdŸ ró¿nicê miêdzy zapisem added_by = NULL, a added_by IS NULL

DELETE FROM dml_exercises.sales 
	WHERE added_by = NULL; -- brak efektów usuwania

/*SELECT * FROM dml_exercises.sales 
	WHERE sales_amount < 200;

SELECT COUNT(*) FROM dml_exercises.sales;
*/
	
DELETE FROM dml_exercises.sales 
	WHERE added_by IS NULL; --rekordy, gdzie added_by jest wartoœci¹ NULL usuniêto poprawnie

/*
SELECT * FROM dml_exercises.sales WHERE sales_amount < 200;

SELECT COUNT(*) FROM dml_exercises.sales;
*/

--Modu³ 3 - Zadanie 9 
--Wyczyœæ wszystkie dane z tabeli sales i zrestartuj sekwencje

TRUNCATE TABLE dml_exercises.sales RESTART IDENTITY;

--SELECT COUNT(*) FROM dml_exercises.sales;

--Modu³ 3 - Zadanie 10 - W tym zadaniu skorzysta³am z zadania 6, a nie 4 zeby mieæ wiêcej rekordów
--DODATKOWE ponownie wstaw do tabeli sales wiersze jak w zadaniu 4.
--Utwórz kopiê zapasow¹ tabeli do pliku. Nastêpnie usuñ tabelê ze schematu dml_exercises i
--odtwórz j¹ z kopii zapasowej.

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