DROP TABLE IF EXISTS policies_clean;
CREATE TABLE policies_clean AS
SELECT 
CAST(IDPol AS INTEGER) AS IDpol,
ClaimNb,
Exposure,
REPLACE(Area, '''', '') AS Area, 
VehPower,
VehAge,
DrivAge,
BonusMalus,
REPLACE(VehBrand, '''', '') AS VehBrand, 
REPLACE(VehGas, '''', '') AS VehGas, 
Density,
REPLACE(Region, '''', '') AS Region
FROM policies