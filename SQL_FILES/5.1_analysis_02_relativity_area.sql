WITH pure_premium_by_area AS (
SELECT 
p.Area,
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
GROUP BY p.Area
ORDER BY p.Area
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
pure_premium_by_area.Area,
pure_premium_by_area.Premium_Capped,
ROUND(pure_premium_by_area.Premium_Capped / pure_premium_overall.Premium_Capped, 3) AS Relativity
 FROM pure_premium_overall, pure_premium_by_area
 ORDER BY pure_premium_by_area.Area