-- Analisi demografica Ticino 1981-2024
-- Query su SQLite, tabella statpop (819'720 righe)
-- Fonte: Ustat / STATPOP


-- 1. I dieci anni con il saldo naturale peggiore
SELECT Anno, Popolazione AS saldo_naturale
FROM statpop
WHERE Cantone_Distretto_Comune = 'Ticino'
  AND Sesso = 'Sesso - totale'
  AND Nazionalità = 'Nazionalità (categoria) - totale'
  AND Statistiche = 'Incremento naturale'
ORDER BY saldo_naturale ASC
LIMIT 10;


-- 2. Totale e media annua delle due componenti della crescita
SELECT Statistiche,
       SUM(Popolazione) AS totale_44_anni,
       ROUND(AVG(Popolazione), 1) AS media_annua,
       MIN(Popolazione) AS peggior_anno,
       MAX(Popolazione) AS miglior_anno
FROM statpop
WHERE Cantone_Distretto_Comune = 'Ticino'
  AND Sesso = 'Sesso - totale'
  AND Nazionalità = 'Nazionalità (categoria) - totale'
  AND Statistiche IN ('Incremento naturale',
                      'Saldo migratorio inclusi i cambiamenti del tipo di popolazione')
GROUP BY Statistiche;


-- 3. I comuni con il maggior deficit di nascite
--    LIKE '5%' isola i comuni (hanno il codice davanti) da cantone e distretti
--    HAVING esclude i comuni con serie storiche incomplete da fusioni recenti
SELECT Cantone_Distretto_Comune AS comune,
       SUM(Popolazione) AS saldo_naturale_cumulato,
       COUNT(*) AS anni_disponibili
FROM statpop
WHERE Statistiche = 'Incremento naturale'
  AND Sesso = 'Sesso - totale'
  AND Nazionalità = 'Nazionalità (categoria) - totale'
  AND Cantone_Distretto_Comune LIKE '5%'
GROUP BY comune
HAVING COUNT(*) >= 40
ORDER BY saldo_naturale_cumulato ASC
LIMIT 15;


-- 4. Variazione anno su anno con window function
--    LAG() confronta ogni riga con la precedente senza self join
SELECT Anno,
       Popolazione AS saldo_naturale,
       LAG(Popolazione) OVER (ORDER BY Anno) AS anno_precedente,
       Popolazione - LAG(Popolazione) OVER (ORDER BY Anno) AS variazione
FROM statpop
WHERE Cantone_Distretto_Comune = 'Ticino'
  AND Sesso = 'Sesso - totale'
  AND Nazionalità = 'Nazionalità (categoria) - totale'
  AND Statistiche = 'Incremento naturale'
ORDER BY Anno DESC
LIMIT 15;