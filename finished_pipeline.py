from pathlib import Path
import sqlite3
import pandas as pd

root = Path(__file__).parent
file = Path(root / "project.db")

file.unlink(missing_ok=True)
file.touch(exist_ok=True)

connection = sqlite3.connect(file)

df = pd.read_csv(root / "freMTPL2freq.csv")
df.to_sql("policies", connection, index=False)
df2 = pd.read_csv(root / "freMTPL2sev.csv")
df2.to_sql("claims", connection, index=False)

sql_folder = Path(root / "SQL_FILES")
sql_sorted = sorted(sql_folder.glob("*.sql"))

csv_folder = Path(root / "CSVs")
csv_folder.mkdir(exist_ok=True)

for sql_file in sql_sorted:
    text = sql_file.read_text()
    print(sql_file.name)
    if ("CREATE TABLE" in text):
        connection.executescript(text)
    else:
        output = pd.read_sql(text, connection)
        output.to_csv(csv_folder / (sql_file.stem + "_output.csv"), index=False)
        

connection.close()        
