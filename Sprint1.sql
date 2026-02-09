USE transactions;

-- Nivell 1
-- Exercici 2. Utilitzant JOIN realitzaràs les següents consultes:
-- Llistat dels països que estan fent compres.
SELECT DISTINCT country
FROM company c
JOIN transaction t ON c.id = t.company_id;

-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country)
FROM company c
JOIN transaction t ON c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name , SUM(amount) AS total_vendes
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY company_name
ORDER BY total_vendes DESC
LIMIT 1; 

-- Exercici 3. Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN 
    (SELECT id
    FROM company
    WHERE country = 'Germany');
    
/*Llista les empreses que han realitzat transaccions per un amount superior 
a la mitjana de totes les transaccions.*/

/*que variables o campos quieren ver? company_name
-- si hay alguna caracteristica a considerar? amount > avg(amount)
-- en donde esta la informacion? company_name en company y amount en transaction
*/
SELECT DISTINCT company_name
FROM company
WHERE id IN (
    SELECT company_id
    FROM transaction
    WHERE amount > 
       (SELECT AVG(amount) 
        FROM transaction));

/*Eliminaran del sistema les empreses que no tenen transaccions registrades, 
entrega el llistat d'aquestes empreses.*/

/*que variables o campos quieren ver? company_name
-- si hay alguna caracteristica a considerar?  sense transaccions
-- en donde esta la informacion? C i T
*/

SELECT company_name
FROM company
WHERE id NOT IN 
      (SELECT company_id
      FROM transaction);
# cal tenir en compte que no estaria contemplant els nulls per aixo es recomanaria fer servir un JOIN

-- Nivell 2
-- Exercici 1
/*Identifica els cinc dies que es va generar la quantitat més gran d'ingressos 
a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.*/

SELECT timestamp, SUM(amount) as total_vendes_dia
FROM transaction
GROUP BY timestamp
ORDER BY total_vendes_dia DESC
LIMIT 5;

-- Exercici 2
/*Quina és la mitjana de vendes per país? Presenta els resultats ordenats 
de major a menor mitjà.*/

SELECT country, AVG(amount) as mitjana_vendes
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY country
ORDER BY mitjana_vendes DESC;

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
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE country = 
     (SELECT country
     FROM company
     WHERE company_name = 'Non Institute');
      


-- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE company_id IN 
      (SELECT id
      FROM company
      WHERE country = 
            (SELECT country
            FROM company
            WHERE company_name = 'Non Institute'));
            
-- Nivell 3

-- Exercici 1
/*Presenta el nom, telèfon, país, data i amount, d'aquelles empreses 
que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 
13 de març del 2024. Ordena els resultats de major a menor quantitat.*/

SELECT company_name, phone, country, timestamp, amount
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE amount BETWEEN 350 AND 400
AND (timestamp LIKE '2015-04-29%' OR timestamp LIKE '2018-07-20%' OR timestamp LIKE '2024-03-13%')  
ORDER BY amount DESC;


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
END AS transaccions
FROM company c 
JOIN transaction t ON c.id = t.company_id
GROUP BY company_name;
