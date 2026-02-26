CREATE DATABASE IF NOT EXISTS sprint_04_transactions;

USE sprint_04_transactions;

CREATE TABLE IF NOT EXISTS transactions (
     id VARCHAR (255) PRIMARY KEY,
     card_id VARCHAR (255),
     business_id VARCHAR(255),
     timestamp TIMESTAMP,
     amount FLOAT,
     declined INT,
     product_ids VARCHAR (255),
     user_id VARCHAR (255),
     lat VARCHAR (255),
     longitude VARCHAR (255)
);

CREATE TABLE IF NOT EXISTS companies (
	 company_id VARCHAR (255) PRIMARY KEY,
     company_name VARCHAR (255),
     phone VARCHAR (255),
     email VARCHAR (255),
     country VARCHAR (255),
     website VARCHAR (255)
);


CREATE TABLE IF NOT EXISTS users (
     id VARCHAR (255) PRIMARY KEY,
     name VARCHAR (255),
     surname VARCHAR (255),
     phone VARCHAR (255),
     email VARCHAR (255),
     birth_date VARCHAR (255),
     country VARCHAR (255),
     city VARCHAR (255),
     postal_code VARCHAR (255),
     website VARCHAR (255),
     continent VARCHAR (255)
);

CREATE TABLE IF NOT EXISTS credit_cards (
     id VARCHAR (255) PRIMARY KEY,
     user_id VARCHAR (255),
     iban VARCHAR(255),
     pan VARCHAR (255),
     pin VARCHAR (255),
     cvv VARCHAR (255),
     track1 VARCHAR (255),
     track2 VARCHAR (255),
     expiring_date VARCHAR (255)
);
# Configuración del Servidor: Ejecutar SET GLOBAL local_infile = 1; en MySQL para permitir la carga local.
-- per alliberar permisos
/*SET GLOBAL local_infile = 1; 
SET GLOBAL local_infile = true; -- activa el permis
SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- COMPROVA si esta actiu el permis
*/

-- carreguem data de l'arxiu .csv de la taula transactions
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

-- carreguem data de l'arxiu .csv de la taula companies
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- carreguem data de l'arxiu .csv de la taula credit_cards
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


-- carreguem data de l'arxiu .csv de la taula users
-- primer american users
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
SET continent= 'american';

-- segon el csv european users
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
SET continent= 'european';

#Nivell 1
# preparem model en estrella
-- eliminem user_id de la taula credit_card per no tenir relacions extres i poder fer model estrella amb transaction
ALTER TABLE credit_cards
DROP COLUMN user_id;

-- TRANSACTIONS creem les foreign key
ALTER TABLE transactions
ADD CONSTRAINT card_id
    FOREIGN KEY (card_id)
    REFERENCES credit_cards(id),
ADD CONSTRAINT business_id
    FOREIGN KEY (business_id)
    REFERENCES companies(company_id),
ADD CONSTRAINT user_id
    FOREIGN KEY (user_id)
    REFERENCES users(id);
    
-- Exercici 1 
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules. 

-- con EXISTS en vez de IN
SELECT *
FROM users AS u
WHERE EXISTS(
      SELECT user_id
      FROM transactions AS t
      WHERE  u.id = user_id
      GROUP BY user_id
      HAVING COUNT(id) > 80
);


SELECT *
FROM users
WHERE id IN(
      SELECT user_id
      FROM transactions
      GROUP BY user_id
      HAVING COUNT(id) > 80
);

-- revisar


/*Exercici 2 
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules. */
-- només utilizant join
SELECT iban, ROUND(AVG(amount), 2) AS avg_amount
     FROM companies c
     INNER JOIN transactions t ON company_id=business_id
     INNER JOIN credit_cards cc ON cc.id = card_id
     WHERE company_name = 'Donec Ltd'
     GROUP BY iban;
     
-- Correcció millor si afegim alias a les columnes
     
-- utilizant subconsulta i join
SELECT iban, ROUND(AVG(amount), 2) AS avg_amount
FROM credit_cards AS cc
JOIN transactions AS t 
     ON cc.id = card_id
WHERE EXISTS ( 
	 SELECT company_id
     FROM companies
     WHERE company_id=business_id 
           AND company_name = 'Donec Ltd')
GROUP BY iban;

/*Nivell 2 
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon: */

CREATE TABLE IF NOT EXISTS credit_cards_status(
   card_id VARCHAR (255),
   status_card VARCHAR (255)
);

-- con el with se piuede inrrooducir los datos saltando pasos

-- inserim dades columna card_id
INSERT INTO credit_cards_status (card_id)
SELECT id
FROM credit_cards;

-- inserim dades a columna status_card
/*UPDATE credit_cards_status AS cs
SET status_card =
    CASE 
      WHEN EXISTS ( 
			SELECT declined 
			FROM transactions AS t
			WHERE t.card_id = cs.card_id
            AND timestamp;*/
   
   

UPDATE credit_cards_status cs
JOIN (SELECT card_id, 
             CASE WHEN MIN(declined)=0 THEN 'actiu'
             ELSE 'inactiu'
             END AS new_status
		FROM (SELECT card_id,declined, timestamp, 
			  ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS row_num
			  FROM transactions) AS co
         WHERE row_num <= 3
         GROUP BY card_id) AS card_declined
ON cs.card_id = card_declined.card_id
SET status_card = new_status;


/*Exercici 1 
Quantes targetes estan actives? */

SELECT COUNT(card_id)
FROM credit_cards_status
WHERE status_card = 'actiu';



/*Nivell 3 
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta: */

-- creacio de la taula
CREATE TABLE IF NOT EXISTS products(
     id VARCHAR (255) PRIMARY KEY,
     product_name VARCHAR (255),
     price VARCHAR(255),
     colour VARCHAR (255),
     weight VARCHAR (255),
     warehaouse_id VARCHAR (255)
);

 
-- carreguem data de l'arxiu .csv de la taula products
LOAD DATA
LOCAL INFILE '/Users/didi/Downloads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- canviem les cloumnes a tipus INT de products i de transaction-products
ALTER TABLE products
MODIFY id INT;

-- creacio taula relacional entre transactions i products
CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR (255),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

-- carrega de dades 
INSERT INTO transaction_products (transaction_id, product_id)
SELECT t.id, jt.product_id
FROM transactions AS t
JOIN JSON_TABLE(
    CONCAT('[', product_ids, ']'),
    "$[*]" COLUMNS (product_id INT PATH "$")
) AS jt;



/* si son massa pesats podem utilitzar index per facilitar la carrega
CREATE INDEX idx_tp_transaction
ON transaction_products(transaction_id);

CREATE INDEX idx_tp_product
ON transaction_products(product_id);*/

/*-- para mejorar el timepo de carga (rendimiento) + modificacion en settings workbench
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;*/

/*  -- comprovacio de quantes files hi ha a la taula/ comporvem que es molt pesada. té 253.391 files.
SELECT COUNT(*) FROM transaction_products;*/



/*Exercici 1 
Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */

SELECT product_id, COUNT(product_id) AS sales_for_product
FROM transaction_products
GROUP BY product_id;