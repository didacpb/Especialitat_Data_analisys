USE transactions;








-- Nivell 1
-- Exercici 2

SELECT DISTINCT c.country
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.declined=0;

-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT c.country) AS paisos_compradors
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.declined=0;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name , ROUND(AVG(t.amount),2) AS total_sales
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.id
ORDER BY total_sales DESC
LIMIT 1; 

-- Exercici 3. Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction AS t
WHERE EXISTS 
    (SELECT c.id
    FROM company AS c
    WHERE c.id=t.company_id AND country = 'Germany')
AND t.declined=0;
    
/*Llista les empreses que han realitzat transaccions per un amount superior 
a la mitjana de totes les transaccions.*/

        
SELECT DISTINCT company_name
FROM company
WHERE EXISTS (
    SELECT company_id
    FROM transaction
    WHERE amount > 
       (SELECT AVG(amount) 
        FROM transaction));

/*Eliminaran del sistema les empreses que no tenen transaccions registrades, 
entrega el llistat d'aquestes empreses.*/


SELECT company_name
FROM company
WHERE id NOT IN(
    SELECT company_id
    FROM transaction
    WHERE declined = 0 );


# cal tenir en compte que no estaria contemplant els nulls per aixo es recomanaria fer servir un JOIN

-- Nivell 2
-- Exercici 1
/*Identifica els cinc dies que es va generar la quantitat més gran d'ingressos 
a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.*/

SELECT DATE_FORMAT(timestamp, '%m-%d-%y') AS transaction_date, SUM(amount) AS total_day_sales
FROM transaction
WHERE declined=0
GROUP BY transaction_date
ORDER BY total_day_sales DESC
LIMIT 5;

-- Exercici 2
/*Quina és la mitjana de vendes per país? Presenta els resultats ordenats 
de major a menor mitjà.*/

SELECT c.country, ROUND(AVG(t.amount)) AS sales_avg
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.declined=0
GROUP BY c.country
ORDER BY sales_avg DESC;

-- Exercici 3
/*En la teva empresa, es planteja un nou projecte per a llançar algunes 
campanyes publicitàries per a fer competència a la companyia "Non Institute". 
Per a això, et demanen la llista de totes les transaccions realitzades 
per empreses que estan situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant JOIN i subconsultes.*/

/*que variables o campos quieren ver? * (transaccions)
-- si hay alguna caracteristica a considerar?  empreses del mateix pais que Non Institute
-- en donde esta la informacion? 
*/

SELECT *
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE c.country = 
     (SELECT c.country
     FROM company AS c
     WHERE c.company_name = 'Non Institute')
AND c.company_name <> 'Non Institute'
AND t.declined=0;

-- Mostra el llistat aplicant solament subconsultes.
SELECT t.*, 
           (SELECT c.id FROM company AS c WHERE c.id =t.company_id) AS company_id,
		   (SELECT c.company_name FROM company AS c WHERE c.id =t.company_id) AS company_name,
		   (SELECT c.phone FROM company AS c WHERE c.id =t.company_id) AS phone,
           (SELECT c.email FROM company AS c WHERE c.id =t.company_id) AS email,
           (SELECT c.country FROM company AS c WHERE c.id =t.company_id) AS country
FROM transaction AS t
WHERE EXISTS
      (SELECT c.id
      FROM company AS c
      WHERE c.id=t.company_id AND c.country = 
            (SELECT c.country
            FROM company AS c
            WHERE c.company_name = 'Non Institute')
		AND c.company_name <> 'Non Institute')
AND t.declined=0;


-- Nivell 3

-- Exercici 1
/*Presenta el nom, telèfon, país, data i amount, d'aquelles empreses 
que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 
13 de març del 2024. Ordena els resultats de major a menor quantitat.*/

SELECT c.company_name, c.phone, c.country, DATE_FORMAT(timestamp, '%m-%d-%y') AS transaction_date, t.amount
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
AND t.declined=0
AND DATE(timestamp) IN ('2015-04-09' , '2018-07-20' , '2024-03-13') 
ORDER BY t.amount DESC;


-- Exercici 2
/*Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat 
operativa que es requereixi, per la qual cosa et demanen la informació 
sobre la quantitat de transaccions que realitzen les empreses, però 
el departament de recursos humans és exigent i vol un llistat de les empreses 
on especifiquis si tenen més de 400 transaccions o menys.*/

/*que variables o campos quieren ver? Nom d'empreses
si hay alguna caracteristica a considerar? mes de 4 transaccion o menys de 4 transaccions
en donde esta la informacion? taules a i b
*/

SELECT company_name, COUNT(t.id) AS total_transactions,
CASE
    WHEN COUNT(t.id) > 400 THEN 'Més de 400 transaccions'
    WHEN COUNT(t.id) < 400 THEN 'Menys de 400 transaccions'
    ELSE 'Exactament 400'
END AS transactions
FROM company AS c 
JOIN transaction AS t ON c.id = t.company_id
GROUP BY c.id;
