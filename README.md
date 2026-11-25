# Reproducible Auto Claims Pipeline

This project uses Python and SQL to pull and analyze large datasets of claim and policy information. It estimates claim frequency, severity, pure premium and relativities for groups by driver age and area for over 600,000 policies. Right now, it's configured to pull and clean data from the freMTPL2 dataset, so it only works on data of that format.

## Notable Findings

Area B was the most heavily skewed, by a policy that was active for only ~2 months but had a claim that was over 4 million euros in severity. To remove such outliers, I capped the contribution from any one claim (by capping claim severity individually at 150,000) when calculating the severity and relativity for both areas and age demographics. This brought Area B's severity from ~3,370 to ~1,845. 

## Relativities

The base case used here was the overall capped pure premium (calculated as the sum of total capped claims per policy divided by the sum of the exposure per policy).

### Relativities by Driver Age

| Age band | Pure premium (capped) | Relativity |
|---|---|---|
| 18-25 | 351.26 | 2.469 |
| 26-35 | 146.38 | 1.029 |
| 36-45 | 128.19 | 0.901 |
| 46-55 | 136.38 | 0.959 |
| 56-65 | 112.70 | 0.792 |
| 66+ | 133.42 | 0.938 |

The relativity is the ratio of the capped premium per age band to the base case.
As shown, the lowest premium is for the age range 56-65, and the highest premium by far is the age range 18-25. This means that people 18-25 create the highest claim costs per policy year for their policies out of all the age ranges. Young drivers have almost twice as much frequency of claims as any other one age group, and the severity of their claims is higher than any other one age group.
When weighted by exposure, the relativities average out to a mean of 1.00, which supports that the relativities for each band are valid.

### Relativities by Area

| Area | Pure premium (capped) | Relativity |
|---|---|---|
| A | 115.41 | 0.811 |
| B | 112.93 | 0.794 |
| C | 124.27 | 0.874 |
| D | 165.55 | 1.164 |
| E | 188.99 | 1.329 |
| F | 145.11 | 1.020 |

The relativity is the ratio of the capped premium per area to the base case.
As shown, the lowest premium is for Area B, though the spread of relativities is much lower than the relativities sorted by age range, and the highest premium is for Area E. This tells us that people in Area E create the highest claim costs per policy year for their policies out of all the areas. By cross-referencing with the frequency table produced by `2.2_clean_area_frequency.sql` and the severity table produced by `4.1_analysis_01_severity_premium_frequency.sql`, we can also see that E's high premium comes from many claims per year (high frequency) paired with average claim severity. Even though Area F has the highest frequency of claims, it also has the smallest claim severity, showing that both factors contribute significantly to premium.
When weighted by exposure, the relativities average out to a mean of 1.00, which supports that the relativities for each area are valid.

## How to run

To run this pipeline, simply open the command prompt on your computer in the project folder and type the following:

`````
pip install pandas
python download_CSV.py
python finished_pipeline.py
`````

The downloaded CSV files and the project.db file will end up in the source folder where the files `download_CSV.py` and `finished_pipeline.py` are located. The finished analyses (and all other intermediate generated CSV files) will go in a newly generated folder titled `CSVs`.

## Data

Below are the datasets used in this pipeline:

### freMTPL2freq.csv

This is the first dataset downloaded from freMTPL2. Most notably, it contains policy IDs, driver & area information, and active policy periods for over 650,000 policies.
Below are all of the columns in the dataset, and a description of the data found in said column:

- `IDpol`: The policy ID corresponding to the policy for its respective row. This is what's used to join this table with the claim severity table.
- `ClaimNb`: The number of claims (as an integer) that the policy had during its exposure period. 
- `Exposure`: The length that the policy for the corresponding row was active, in years. Policies can have exposure anywhere from 0.00274 years to 2.01 years.
- `Area`: The area code that corresponds to the policy. Can be A, B, C, D, E or F. A is the most rural, F is the most urban.
- `VehPower`: The power of the vehicle that is under the policy for the corresponding row. This isn't used in our analysis.
- `VehAge`: The age of the vehicle that is under the policy for the corresponding row. This isn't used in our analysis.
- `DrivAge`: The age of the driver under the policy for the corresponding row. Ages vary from 18 to 100, but in our analysis, we group them into 'age bands.'
- `BonusMalus`: The bonus-malus for the policy of the corresponding row. Lower values (<100) means a claims-free history and affords a discount, while higher values (>100) means that the policyholder has a history of claims and makes it more expensive. This isn't used in our analysis.
- `VehBrand`: The brand of the vehicle that is under the policy for the corresponding row (denoted from B1 to B14). This isn't used in our analysis.
- `VehGas`: The gas that the vehicle under the policy for the corresponding row runs on. Either 'Diesel' or 'Regular.' This isn't used in our analysis.
- `Density`: The population density, measured in inhabitants per square kilometer, of the place where the driver under the policy lives. This isn't used in our analysis.
- `Region`: The region in France where the policy is held (denoted from R11 to R94). This isn't used in our analysis.

### freMTPL2sev.csv

This is the second dataset downloaded from freMTPL2. It is much less information-dense than the first dataset, containing two columns and a little over 26,500 rows.
Below are the columns in the dataset, and a description of the data found in said column:

- `IDpol`: The policy ID corresponding to the policy that the claim occurred under. This is what's used to join this table with the policy table.
- `ClaimAmount`: The severity of the claim in euros. A claim can range anywhere from 1 euro to ~4.1 million euros.

## Method

### Steps 

The first step in the analysis was writing SQL scripts to convert the 'dirty' data into clean data. In the initial CSV files, the `Area`, `VehBrand`, `VehGas`, `Region` had quotations covering the values in the cells, and the `IDpol` columns for both tables had to be converted to integers to guarantee they matched (one was already whole numbers, but one was in decimal form). This was fixed by using SQL `REPLACE` and `CAST` functions. Finally, the two tables had to be joined, such that none of the policyless claims exist in the joined table, so `INNER JOIN` was used for this.

The second step was the frequency table. This wasn't a requirement for anything downstream, but the data helped create a complete view of the findings. This was done by taking the `SUM` of claims for each policy area, divided by the `SUM` of exposure for each policy area. This was done rather than taking the average of claims divided by exposure for each policy in an area because the latter gives too much weight to short policies that happen to have claims (e.g. a policy that runs for a week but happens to have a claim unrealistically assumes 52 claims per year).

The third step was the severities table. I wrote SQL scripts for both the uncapped and capped severities (with a cap of 150,000 for any one claim's payout to avoid skewing due to outlier payouts). The formula for severity was the `SUM` of the payouts for a group of policies divided by the `COUNT` of claims for the same group of policies. The formula for pure premium was the `SUM` of the payouts for a group of policies divided by the `SUM` of exposure in years for the same group of policies. To avoid multi-counting exposure for each time it appeared in the claims table, I used `GROUP BY IDpol` and summed up the claim amounts for each policy first to ensure that every policy only had one row, and thus exposure was only counted once for each. In this analysis, the policies were grouped by `Area` in this step and would be grouped by `DrivAge` bands as well in the later step.

The final step was the relativities tables. I wrote SQL scripts to group relativities by both `DrivAge` bands and `Area`. The relativities for the areas were found by taking the capped pure premiums using the same script as the previous step, using `GROUP BY Area`, and then dividing by overall capped pure premium to get relativity for each area. The same method was used for the `DrivAge` bands, but they had to be split into `AgeBand` rows by taking `CASE WHEN DrivAge <= X THEN 'BAND'`. The bands used were 18-25, 26-35, 36-45, 46-55, 56-65 and 66+.

### SQL Files

| File | Purpose |
|---|---|
| `1.1_clean_policy_script.sql` | Cleans the policy CSV by removing quotations and normalizing the `IDpol` values into integers. |
| `1.2_clean_claims_script.sql` | Cleans the claims CSV by normalizing the `IDpol` values into integers, and then uses `INNER JOIN ON IDpol` to join with the clean policy table.  |
| `2.2_clean_area_frequency.sql` | Finds the frequency of claims (total claims on all policies over total policy exposure) for each `Area`. |
| `3_consistency_check.sql` | Ensures that the clean tables have rows consistent with the policy and claims tables. |
| `4.1_analysis_01_severity_premium_frequency.sql` | Finds the severity of claims (total claim payouts over amount of claims) for each `Area`. Then finds the pure premium (total claim payouts over total exposure from policies) for each `Area`. Instates a cap of 150,000 on any individual claim's contribution to total payouts. |
| `4.2_analysis_01_severity_premium_frequency_uncapped.sql` | Finds the severity of claims (total claim payouts over amount of claims) for each `Area`. Then finds the pure premium (total claim payouts over total exposure from policies) for each `Area`. Instates no cap. |
| `5.1_analysis_02_relativity_area.sql` | Finds the relativity (capped pure premiums for a certain group over overall capped pure premium), grouping based on policyholder `Area`. |
| `5.2_analysis_02_relativity_age.sql` | Finds the relativity (capped pure premiums for a certain group over overall capped pure premium), grouping based on policyholder age band. |

## Decisions

- There were many claim rows that paid out exactly 1204. Of these, over 200 shared the same `IDpol` as well. While these could be duplicates, they were kept due to having no claim IDs to differentiate them, and 1204 was so common that the shared claim amounts are not a strong baseline for deducing duplication.
- There were 9000+ policies that had a nonzero amount of claims (`ClaimNb` in `freMTPL2freq.csv`) but had no corresponding claim amounts for such claims (No rows in `freMTPL2sev.csv`). This was the main contributing factor in my decision to evaluate frequencies separately from severities.
- I chose 150,000 as the cap because it was large enough to only affect a tiny amount of claims, around 0.1%, but also small enough to significantly quash any form of skewing due to outliers.

## Limitations

- Each category (driver age, area) in grouping policies was looked at alone, meaning the analysis doesn't account for any potential correlation between driver age and driver area. This is what GLMs are for, but those are much harder to write scripts for via SQL.
- As shown in the column summary for `freMTPL2freq.csv`, many potential accident grouping categories were untouched. In the future, the analysis could be expanded to include more categories.
- The excess resulting from the caps is completely discarded, which does give an incomplete view of the actual expenses of each policy. While an analysis without a cap DOES exist, there is no analysis that redistributes the excess of the cap across all policies, which would allow for a fuller view of true policy pure premium.
- The results are dependent on the choice for the cap amount and the choices for age bands (electing different numbers for either would have yielded different results).