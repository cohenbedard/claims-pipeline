SELECT Area, COUNT(*) AS Policies, SUM(ClaimNb) AS NumberOfClaims, ROUND(SUM(Exposure),2) AS ExposureYears, ROUND(SUM(ClaimNb)/SUM(Exposure), 4) AS ClaimFrequency FROM policies_clean
GROUP BY Area

UNION ALL

SELECT 
'Total' AS Area,
COUNT(*),
SUM(ClaimNb),
ROUND(SUM(Exposure),1),
ROUND(SUM(ClaimNb) / SUM(Exposure), 4)
FROM policies_clean

ORDER BY Area Asc