import pandas as pd
from pathlib import Path

root = Path(__file__).parent

freq_url = "https://www.openml.org/data/get_csv/20649148/freMTPL2freq.arff"
sev_url = "https://www.openml.org/data/get_csv/20649149/freMTPL2sev.arff"
freq_df = pd.read_csv(freq_url)
sev_df = pd.read_csv(sev_url)

freq_df.to_csv(root / "freMTPL2freq.csv", index=False)
sev_df.to_csv(root / "freMTPL2sev.csv", index=False)

print("Policies have been downloaded")
print("Downloaded from " + freq_url + ", " + sev_url)
