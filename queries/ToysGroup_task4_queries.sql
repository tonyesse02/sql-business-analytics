-- 4
-- 4.1 verifica valori univoci --
SELECT CategoryID, COUNT(*) AS Conteggio
FROM category
GROUP BY CategoryID
HAVING COUNT(*) > 1;

SELECT RegionID, COUNT(*) AS Conteggio
FROM salesregion
GROUP BY RegionID
HAVING COUNT(*) > 1;

SELECT CountryID, COUNT(*) AS Conteggio
FROM country
GROUP BY CountryID
HAVING COUNT(*) > 1;

SELECT SalesID, COUNT(*) AS Conteggio
FROM sales
GROUP BY SalesID
HAVING COUNT(*) > 1;

-- --------------------------------------------------
-- 4
-- 4.2 elenco transazioni --
SELECT
  s.DocCode
  , s.SalesDate
  , p.ProductName
  , ca.CategoryName
  , co.CountryName
  , r.RegionName
  , CASE
    WHEN DATEDIFF(CURDATE(), s.SalesDate) > 180 THEN TRUE
    ELSE FALSE
  END AS Over180 
 , DATEDIFF(CURDATE(), s.SalesDate) -180 as DiffDate
FROM sales s
JOIN product p  
ON p.ProductID = s.ProductID
JOIN category ca
ON ca.CategoryID = p.CategoryID
JOIN country co
ON co.CountryID = s.CountryID
JOIN salesregion r
ON r.RegionID = co.RegionID
ORDER BY s.SalesDate DESC, s.DocCode;

-- --------------------------------------------------
-- 4
-- 4.3 elenco transazioni --
WITH ultimo_anno AS (
  SELECT MAX(YEAR(SalesDate)) AS anno
  FROM sales
),

vendite_ultimo_anno AS (
  SELECT
    ProductID,
    SUM(Quantity) AS quantita_ultimo_anno
  FROM sales
  WHERE YEAR(SalesDate) = (SELECT anno FROM ultimo_anno)
  GROUP BY ProductID
),

media_ultimo_anno AS (
  SELECT AVG(quantita_ultimo_anno) AS media_vendite
  FROM vendite_ultimo_anno
),

vendite_totali AS (
  SELECT
    ProductID,
    SUM(Quantity) AS totale_venduto
  FROM sales
  GROUP BY ProductID
)

SELECT
  v.ProductID,
  v.totale_venduto
FROM vendite_totali v
JOIN media_ultimo_anno m
WHERE v.totale_venduto > m.media_vendite
ORDER BY v.totale_venduto DESC;

-- --------------------------------------------------
-- 4
-- 4.4 fatturato per prodotto per anno --
SELECT
  s.ProductID
  , p.ProductName
  , YEAR(s.SalesDate) AS Anno
  , SUM(s.Quantity * s.UnitPrice) AS FatturatoTotale
FROM sales s
JOIN product p ON p.ProductID = s.ProductID
GROUP BY s.ProductID, 
ProductName,
YEAR(s.SalesDate)
ORDER BY Anno ASC, 
FatturatoTotale DESC;

-- --------------------------------------------------
-- 4
-- 4.5 fatturato per stato per anno --
SELECT
  c.CountryName AS Stato,
  YEAR(s.SalesDate) AS Anno,
  SUM(s.Quantity * s.UnitPrice) AS FatturatoTotale
FROM sales s
JOIN country c ON c.CountryID = s.CountryID
GROUP BY
  c.CountryName,
  YEAR(s.SalesDate)
ORDER BY
  Anno ASC,
  FatturatoTotale DESC;

-- --------------------------------------------------
-- 4
-- 4.6 categoria più richiesta --
SELECT
  c.CategoryName,
  SUM(s.Quantity) AS TotaleVenduto
FROM sales s
JOIN product p ON p.ProductID = s.ProductID
JOIN category c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY TotaleVenduto DESC;

-- --------------------------------------------------
-- 4
-- 4.7 prodotti invenduti --
-- approccio 1 --
SELECT
  product.ProductID,
  product.ProductName
FROM product
LEFT JOIN sales
  ON sales.ProductID = product.ProductID
WHERE sales.ProductID IS NULL;

-- approccio 2 --

SELECT
  ProductID,
  ProductName
FROM product
WHERE ProductID NOT IN (
  SELECT ProductID
  FROM sales
);

-- --------------------------------------------------
-- 4
-- 4.8 vista prodotti --

CREATE VIEW vista_prodotti AS
SELECT
  product.ProductID,
  product.ProductName,
  category.CategoryName
FROM product
JOIN category
  ON category.CategoryID = product.CategoryID;

SELECT * FROM vista_prodotti;

-- --------------------------------------------------
-- 4
-- 4.9 vista geografica  --

CREATE VIEW vista_geografica AS
SELECT
  c.CountryID,
  c.CountryName,
  r.RegionID,
  r.RegionName
FROM country c
JOIN salesregion r
  ON r.RegionID = c.RegionID;

SELECT * FROM vista_geografica;