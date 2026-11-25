DROP TABLE IF EXISTS claims_clean;
CREATE TABLE claims_clean AS
SELECT 
CAST(claims.IDpol AS INTEGER) AS IDpol, ClaimAmount FROM claims
INNER JOIN policies_clean ON policies_clean.IDpol = claims.IDpol;