-- Exercici 1 
/*A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.*/

    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
CREATE TABLE IF NOT EXISTS credit_card
(
	id VARCHAR (10) PRIMARY KEY,
    iban VARCHAR (250) NOT NULL,
    pan VARCHAR (30) NOT NULL,
    pin INT(4) NOT NULL,
    cvv INT(3) NOT NULL,
    expiring_date VARCHAR(10)
    );
  
       

    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) /*REFERENCES credit_card(id)*/,
        company_id VARCHAR(20), 
        user_id INT /*REFERENCES user(id)*/,
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    -- afegim restriccio a FK credit card id de transaction
    ALTER TABLE transaction
    ADD CONSTRAINT credit_cars_id
    FOREIGN KEY (credit_card_id)
    REFERENCES credit_card(id);
    
/*Exercici 2 

El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar. */
-- comprovem l'estat de la petició
SELECT *
FROM credit_card
WHERE id='CcU-2938';

UPDATE credit_card
SET iban='TR323456312213576817699999'
WHERE id='CcU-2938';

-- comprovem canvi
SELECT *
FROM credit_card
WHERE id='CcU-2938';

/*Exercici 3 

En la taula "transaction" ingressa una nova transacció amb la següent informació: */
-- la credit card no existeix a la taula cc aixi que l hem de crear primer, sino la restriccio ens donara null
INSERT INTO credit_card (id,iban,pan,pin,cvv) values('CcU-9999', 'TEST', 00000,0000,000);
-- El mateix a company
INSERT INTO company(id) VALUES('b-9999');
-- afegim a transaction
INSERT INTO transaction (id, credit_card_id,company_id,user_id,lat,longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999','b-9999',9999,829.999,-117.999,111.11,0);

/*Exercici 4 
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat. */
ALTER TABLE credit_card DROP COLUMN pan;

/* Nivell 2 

Exercici 1 

Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades. */
-- comprovem que hi és 
SELECT* FROM transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
-- esborrem
DELETE FROM transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
-- comprovem que s'ha esborrat correctament
SELECT* FROM transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

/*Exercici 2 
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra. */

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(amount), 2) AS total_sales
FROM company AS c
JOIN transaction AS t
 ON c.id=t.company_id
GROUP BY c.id
ORDER BY total_sales DESC;


/*Exercici 3 
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany" */
SELECT *
FROM VistaMarketing
WHERE country= 'Germany';

/*Nivell 3 
Exercici 1 
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: */

-- introduim estructura dades de user
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- canvi tipus de dades de la columna id a user
ALTER TABLE user
MODIFY id INT,
RENAME COLUMN email to personal_email;

-- ingressem dades a la taula user
-- introduim user 9999 que hem fet anteriorment a un exercici perq no restringeixi la relacio amb transaction
INSERT INTO user(id)
VALUES('9999');

-- creem relacio user i transaction

ALTER TABLE transaction
ADD CONSTRAINT user_id
FOREIGN KEY (user_id)
REFERENCES user(id);

-- treiem website de company

ALTER TABLE company
DROP COLUMN website;

-- Alterem taula credit_card
ALTER TABLE credit_card
ADD fecha_actual DATE,
MODIFY iban VARCHAR (50),
MODIFY pin VARCHAR (4),
MODIFY cvv INT
;

-- treiem vistamarketing
DROP VIEW VistaMarketing;
/*Exercici 2 
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació: 
  ID de la transacció 
  Nom de l'usuari/ària 
  Cognom de l'usuari/ària 
  IBAN de la targeta de crèdit usada. 
  Nom de la companyia de la transacció realitzada. 
  Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui. 
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció. */

CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaccion, u.name AS nombre_usuario, u.surname AS apellido_usuario,
       cc.iban AS iban_tarjeta_credito, c.company_name AS nombre_compañia , t.timestamp AS fecha_de_transaccion
FROM transaction AS t
JOIN company AS c ON c.id=t.company_id
JOIN credit_card AS cc ON cc.id=t.credit_card_id
JOIN user AS u ON u.id=t.user_id
ORDER BY id_transaccion DESC;

-- comprovació
SELECT *
FROM InformeTecnico;