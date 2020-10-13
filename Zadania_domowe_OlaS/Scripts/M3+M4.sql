/*********************************************************************************************************************************/
/************************************************************* MODUL 3 ***********************************************************/
/*********************************************************************************************************************************/

--Modu� 3 - Zadanie 1 
--Utw�rz nowy schemat o nazwie training

CREATE SCHEMA training;


--Modu� 3 - Zadanie 2 
--Zmie� nazw� schematu na training_zs

ALTER SCHEMA training RENAME TO training_zs;


--Modu� 3 - Zadanie 3
--Korzystaj�c z konstrukcji <nazwa_schematy>.<nazwa_tabeli> lub ��cz�c si� DO schematu training_zs, utw�rz tabel� wed�ug opisu.
-- Tabela: products; 
-- Kolumny: 
--  id - typ ca�kowity, 
--  production_qty - typ zmiennoprzecinkowy (numeric - 10 znak�w i do 2 znak�w po przecinku)
--  product_name - typ tekstowy 100 znak�w (NIE STALA ILOSC - patrz varchar)
--  product_code - typ tekstowy 10 znak�w
--  description - typ tekstowy nieograniczona ilo�� znak�w
--  manufacturing_date - typ data (sama data bez cz�ci godzin, minut, sekund)
 
CREATE TABLE IF NOT EXISTS training_zs.products (
		id INT,
		production_qty NUMERIC(10,2),
		product_name VARCHAR(100),
		product_code CHAR(10),
		description TEXT,
		manufacturing_date DATE
);


--Modu� 3 - Zadanie 4 
--Korzystaj�c ze sk�adni ALTER TABLE, dodaj klucz g��wny do tabeli products dla pola ID.

ALTER TABLE training_zs.products ADD CONSTRAINT pk_products PRIMARY KEY (id);


--Modu� 3 - Zadanie 5 
--Korzystaj�c ze sk�adni IF EXISTS spr�buj usun�� tabel� sales ze schematu training_zs

DROP TABLE IF EXISTS training_zs.sales;


--Modu� 3 - Zadanie 6
--W schemacie training_zs, utw�rz now� tabel� sales wed�ug opisu.
-- Tabela: sales; 
-- Kolumny: 
--  id - typ ca�kowity, klucz g��wny, 
--  sales_date - typ data i czas (data + cz�� godziny, minuty, sekundy), to pole ma nie zawiera� warto�ci nieokre�lonych NULL,
--  sales_amount - typ zmiennoprzecinkowy (NUMERIC 38 znak�w, do 2 znak�w po przecinku)
--  sales_qty - typ zmiennoprzecinkowy (NUMERIC 10 znak�w, do 2 znak�w po przecinku)
--  product_id - typ ca�kowity INTEGER
--  added_by - typ tekstowy (nielimitowana ilo�� znak�w), z warto�ci� domy�ln� 'admin'
--- UWAGA: nie ma tego w materia�ach wideo. Przeczytaj o atrybucie DEFAULT dla kolumny https://www.postgresql.org/docs/12/ddl-default.html 
--  korzystaj�c z definiowania przy tworzeniu tabeli, po definicji kolumn, dodaj ograniczenie o nazwie sales_over_1k na polu sales_amount typu CHECK takie, �e warto�ci w polu sales_amount musz� by� wi�ksze od 1000

CREATE TABLE IF NOT EXISTS training_zs.sales(
		id INT PRIMARY KEY,
		sales_date TIMESTAMP NOT NULL,
		sales_amount NUMERIC(38, 2),
		sales_qty NUMERIC(10, 2),
		product_id INT,
		added_by TEXT DEFAULT 'Admin',
		CONSTRAINT sales_over_1k CHECK (sales_amount > 1000)
);


--Modu� 3 - Zadanie 7
--Korzystaj�c z operacji ALTER utw�rz powi�zanie mi�dzy tabel� sales i products, jako klucz obcy pomi�dzy atrybutami product_id z tabeli sales i id z tabeli products.
--Dodatkowo nadaj kluczowi obcemu opcj� ON DELETE CASCADE

ALTER TABLE training_zs.sales ADD CONSTRAINT sales_products_fk FOREIGN KEY (product_id) REFERENCES training_zs.products(id) ON DELETE CASCADE;


--Modu� 3 - Zadanie 8
--Korzystaj�c z polecenia DROP i opcji CASCADE usu� schemat training_zs

DROP SCHEMA training_zs CASCADE;

/*********************************************************************************************************************************/
/************************************************************* MODUL 4 ***********************************************************/
/*********************************************************************************************************************************/

--Modu� 4 - Zadanie 1
-- Korzystaj�c ze sk�adni CREATE ROLE, stw�rz nowego u�ytkownika o nazwie user_training z
--mo�liwo�ci� zalogowania si� do bazy danych i has�em silnym

CREATE ROLE user_training WITH LOGIN PASSWORD 'TrudneHaslo111@';


--Modu� 4 - Zadanie 2
--Korzystaj�c z atrybutu AUTHORIZATION dla sk�adni CREATE SCHEMA. 
--Utw�rz schemat training, kt�rego w�a�cicielem b�dzie u�ytkownik user_training.

CREATE SCHEMA training AUTHORIZATION user_training;


--Modu� 4 - Zadanie 3
--B�d�c zalogowany na super u�ytkowniku postgres, spr�buj usun�� rol� (u�ytkownika) user_training

DROP ROLE user_training; -- nie ma uprawnie� do usuniecia, wi�c si� nie powiod�o


--Modu� 4 - Zadanie 4
--Przeka� w�asno�� nad utworzonym dla / przez u�ytkownika user_training obiektami na role postgres.
--Nast�pnie usu� role user_training.

REASSIGN OWNED BY user_training TO postgres;

DROP ROLE user_training;


--Modu� 4 - Zadanie 5
-- Utw�rz now� rol� reporting_ro, kt�ra b�dzie grup� dost�p�w, dla u�ytkownik�w warstwy analitycznej o nast�puj�cych przywilejach.
	--Dost�p do bazy danych postgres
	--Dost�p do schematu training
	--Dost�p do tworzenia obiekt�w w schemacie training
	--Dost�p do wszystkich uprawnie� dla wszystkich tabel w schemacie training

DROP ROLE IF EXISTS reporting_ro;

CREATE ROLE reporting_ro;

GRANT CONNECT ON DATABASE postgres TO reporting_ro;

GRANT USAGE, CREATE ON SCHEMA training TO reporting_ro;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA training TO reporting_ro;


--Modu� 4 - Zadanie 6
--Utw�rz nowego u�ytkownika reporting_user z mo�liwo�ci� logowania si� do bazy danych i ha�le silnym :)
--Przypisz temu u�ytkownikowi role reporting ro;

CREATE ROLE reporting_user WITH LOGIN PASSWORD 'TrudneHaslo222@';

GRANT reporting_ro TO reporting_user;

--Modu� 4 - Zadanie 7
--B�d�c zalogowany na u�ytkownika reporting_user, spr�buj utworzy� now� tabele (dowoln�)
--w schemacie training.

CREATE TABLE training.test (id INT); -- uda�o si� stworzy� now� tabel�


--Modu� 4 - Zadanie 8
--Zabierz uprawnienia roli reporting_ro do tworzenia obiekt�w w schemacie training

REVOKE CREATE ON SCHEMA training FROM reporting_ro;


--Modu� 4 - Zadanie 9
--Zaloguj si� ponownie na u�ytkownika reporting_user, sprawd� czy mo�esz utworzy� now�
--tabel� w schemacie training oraz czy mo�esz tak� tabel� utworzy� w schemacie public.


CREATE TABLE training.test2 (id INT); -- nie uda�o si� stworzy� nowej tabeli

CREATE TABLE public.test2 (id INT); -- (CREATE TABLE test2) - uda�o si� stworzy� now� tabel�







