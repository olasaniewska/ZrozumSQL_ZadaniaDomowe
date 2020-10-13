/*********************************************************************************************************************************/
/************************************************************* MODUL 3 ***********************************************************/
/*********************************************************************************************************************************/

--Modu³ 3 - Zadanie 1 
--Utwórz nowy schemat o nazwie training

CREATE SCHEMA training;


--Modu³ 3 - Zadanie 2 
--Zmieñ nazwê schematu na training_zs

ALTER SCHEMA training RENAME TO training_zs;


--Modu³ 3 - Zadanie 3
--Korzystaj¹c z konstrukcji <nazwa_schematy>.<nazwa_tabeli> lub ³¹cz¹c siê DO schematu training_zs, utwórz tabelê wed³ug opisu.
-- Tabela: products; 
-- Kolumny: 
--  id - typ ca³kowity, 
--  production_qty - typ zmiennoprzecinkowy (numeric - 10 znaków i do 2 znaków po przecinku)
--  product_name - typ tekstowy 100 znaków (NIE STALA ILOSC - patrz varchar)
--  product_code - typ tekstowy 10 znaków
--  description - typ tekstowy nieograniczona iloœæ znaków
--  manufacturing_date - typ data (sama data bez czêœci godzin, minut, sekund)
 
CREATE TABLE IF NOT EXISTS training_zs.products (
		id INT,
		production_qty NUMERIC(10,2),
		product_name VARCHAR(100),
		product_code CHAR(10),
		description TEXT,
		manufacturing_date DATE
);


--Modu³ 3 - Zadanie 4 
--Korzystaj¹c ze sk³adni ALTER TABLE, dodaj klucz g³ówny do tabeli products dla pola ID.

ALTER TABLE training_zs.products ADD CONSTRAINT pk_products PRIMARY KEY (id);


--Modu³ 3 - Zadanie 5 
--Korzystaj¹c ze sk³adni IF EXISTS spróbuj usun¹æ tabelê sales ze schematu training_zs

DROP TABLE IF EXISTS training_zs.sales;


--Modu³ 3 - Zadanie 6
--W schemacie training_zs, utwórz now¹ tabelê sales wed³ug opisu.
-- Tabela: sales; 
-- Kolumny: 
--  id - typ ca³kowity, klucz g³ówny, 
--  sales_date - typ data i czas (data + czêœæ godziny, minuty, sekundy), to pole ma nie zawieraæ wartoœci nieokreœlonych NULL,
--  sales_amount - typ zmiennoprzecinkowy (NUMERIC 38 znaków, do 2 znaków po przecinku)
--  sales_qty - typ zmiennoprzecinkowy (NUMERIC 10 znaków, do 2 znaków po przecinku)
--  product_id - typ ca³kowity INTEGER
--  added_by - typ tekstowy (nielimitowana iloœæ znaków), z wartoœci¹ domyœln¹ 'admin'
--- UWAGA: nie ma tego w materia³ach wideo. Przeczytaj o atrybucie DEFAULT dla kolumny https://www.postgresql.org/docs/12/ddl-default.html 
--  korzystaj¹c z definiowania przy tworzeniu tabeli, po definicji kolumn, dodaj ograniczenie o nazwie sales_over_1k na polu sales_amount typu CHECK takie, ¿e wartoœci w polu sales_amount musz¹ byæ wiêksze od 1000

CREATE TABLE IF NOT EXISTS training_zs.sales(
		id INT PRIMARY KEY,
		sales_date TIMESTAMP NOT NULL,
		sales_amount NUMERIC(38, 2),
		sales_qty NUMERIC(10, 2),
		product_id INT,
		added_by TEXT DEFAULT 'Admin',
		CONSTRAINT sales_over_1k CHECK (sales_amount > 1000)
);


--Modu³ 3 - Zadanie 7
--Korzystaj¹c z operacji ALTER utwórz powi¹zanie miêdzy tabel¹ sales i products, jako klucz obcy pomiêdzy atrybutami product_id z tabeli sales i id z tabeli products.
--Dodatkowo nadaj kluczowi obcemu opcjê ON DELETE CASCADE

ALTER TABLE training_zs.sales ADD CONSTRAINT sales_products_fk FOREIGN KEY (product_id) REFERENCES training_zs.products(id) ON DELETE CASCADE;


--Modu³ 3 - Zadanie 8
--Korzystaj¹c z polecenia DROP i opcji CASCADE usuñ schemat training_zs

DROP SCHEMA training_zs CASCADE;

/*********************************************************************************************************************************/
/************************************************************* MODUL 4 ***********************************************************/
/*********************************************************************************************************************************/

--Modu³ 4 - Zadanie 1
-- Korzystaj¹c ze sk³adni CREATE ROLE, stwórz nowego u¿ytkownika o nazwie user_training z
--mo¿liwoœci¹ zalogowania siê do bazy danych i has³em silnym

CREATE ROLE user_training WITH LOGIN PASSWORD 'TrudneHaslo111@';


--Modu³ 4 - Zadanie 2
--Korzystaj¹c z atrybutu AUTHORIZATION dla sk³adni CREATE SCHEMA. 
--Utwórz schemat training, którego w³aœcicielem bêdzie u¿ytkownik user_training.

CREATE SCHEMA training AUTHORIZATION user_training;


--Modu³ 4 - Zadanie 3
--Bêd¹c zalogowany na super u¿ytkowniku postgres, spróbuj usun¹æ rolê (u¿ytkownika) user_training

DROP ROLE user_training; -- nie ma uprawnieñ do usuniecia, wiêc siê nie powiod³o


--Modu³ 4 - Zadanie 4
--Przeka¿ w³asnoœæ nad utworzonym dla / przez u¿ytkownika user_training obiektami na role postgres.
--Nastêpnie usuñ role user_training.

REASSIGN OWNED BY user_training TO postgres;

DROP ROLE user_training;


--Modu³ 4 - Zadanie 5
-- Utwórz now¹ rolê reporting_ro, która bêdzie grup¹ dostêpów, dla u¿ytkowników warstwy analitycznej o nastêpuj¹cych przywilejach.
	--Dostêp do bazy danych postgres
	--Dostêp do schematu training
	--Dostêp do tworzenia obiektów w schemacie training
	--Dostêp do wszystkich uprawnieñ dla wszystkich tabel w schemacie training

DROP ROLE IF EXISTS reporting_ro;

CREATE ROLE reporting_ro;

GRANT CONNECT ON DATABASE postgres TO reporting_ro;

GRANT USAGE, CREATE ON SCHEMA training TO reporting_ro;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA training TO reporting_ro;


--Modu³ 4 - Zadanie 6
--Utwórz nowego u¿ytkownika reporting_user z mo¿liwoœci¹ logowania siê do bazy danych i haœle silnym :)
--Przypisz temu u¿ytkownikowi role reporting ro;

CREATE ROLE reporting_user WITH LOGIN PASSWORD 'TrudneHaslo222@';

GRANT reporting_ro TO reporting_user;

--Modu³ 4 - Zadanie 7
--Bêd¹c zalogowany na u¿ytkownika reporting_user, spróbuj utworzyæ now¹ tabele (dowoln¹)
--w schemacie training.

CREATE TABLE training.test (id INT); -- uda³o siê stworzyæ now¹ tabelê


--Modu³ 4 - Zadanie 8
--Zabierz uprawnienia roli reporting_ro do tworzenia obiektów w schemacie training

REVOKE CREATE ON SCHEMA training FROM reporting_ro;


--Modu³ 4 - Zadanie 9
--Zaloguj siê ponownie na u¿ytkownika reporting_user, sprawdŸ czy mo¿esz utworzyæ now¹
--tabelê w schemacie training oraz czy mo¿esz tak¹ tabelê utworzyæ w schemacie public.


CREATE TABLE training.test2 (id INT); -- nie uda³o siê stworzyæ nowej tabeli

CREATE TABLE public.test2 (id INT); -- (CREATE TABLE test2) - uda³o siê stworzyæ now¹ tabelê







