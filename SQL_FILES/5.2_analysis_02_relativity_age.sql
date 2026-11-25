WITH pure_premium_by_age AS (
SELECT 
CASE
    WHEN p.DrivAge <= 25 THEN '18-25'
    WHEN p.DrivAge <= 35 THEN '26-35'
    WHEN p.DrivAge <= 45 THEN '36-45'
    WHEN p.DrivAge <= 55 THEN '46-55'
    WHEN p.DrivAge <= 65 THEN '56-65'
    ELSE '66+'
END AS AgeBand,
COUNT(*) AS Policies,
ROUND(SUM(p.Exposure), 1) AS ExposureYears,
SUM(c.Claims_Amounts) AS Claims_Amounts,
ROUND(SUM(c.Claims_Total), 0) AS Claims_Total_Capped,
ROUND(SUM(c.Claims_Total) / SUM(c.Claims_Amounts), 2) AS Severity_Capped,
ROUND(SUM(c.Claims_Total) / SUM(p.Exposure), 2) AS Premium_Capped
FROM policies_clean AS p
LEFT JOIN (SELECT claims_clean.IDpol, 
COUNT(claims_clean.IDpol) AS Claims_Amounts,
SUM(MIN(ClaimAmount, 150000)) AS Claims_Total
FROM claims_clean
LEFT JOIN policies_clean ON claims_clean.IDpol = policies_clean.IDpol
GROUP BY claims_clean.IDpol)
AS c ON p.IDpol = c.IDpol
GROUP BY AgeBand
ORDER BY AgeBand
),
pure_premium_overall AS (
SELECT 
COUNT(*) AS Policies,
ROUND(SUM(p.Exposure), 1) AS ExposureYears,
SUM(c.Claims_Amounts) AS Claims_Amounts,
ROUND(SUM(c.Claims_Total), 0) AS Claims_Total_Capped,
ROUND(SUM(c.Claims_Total) / SUM(c.Claims_Amounts), 2) AS Severity_Capped,
ROUND(SUM(c.Claims_Total) / SUM(p.Exposure), 2) AS Premium_Capped
FROM policies_clean AS p
LEFT JOIN (SELECT claims_clean.IDpol, 
COUNT(claims_clean.IDpol) AS Claims_Amounts,
SUM(MIN(ClaimAmount, 150000)) AS Claims_Total
FROM claims_clean
LEFT JOIN policies_clean ON claims_clean.IDpol = policies_clean.IDpol
GROUP BY claims_clean.IDpol)
AS c ON p.IDpol = c.IDpol
)
SELECT
pure_premium_by_age.AgeBand,
pure_premium_by_age.Premium_Capped,
ROUND(pure_premium_by_age.Premium_Capped / pure_premium_overall.Premium_Capped, 3) AS Relativity
 FROM pure_premium_overall, pure_premium_by_age
 ORDER BY pure_premium_by_age.AgeBand