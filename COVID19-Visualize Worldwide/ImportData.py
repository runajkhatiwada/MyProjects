import requests as rq
import json as js
import pandas as pd
import pyodbc as po
from datetime import datetime
pd.set_option("display.max.columns", None)

url = "https://api.statworx.com/covid"

conn = po.connect('Driver={SQL Server};' 'Server=RUNAJ\INSTANCE2016;' 'Database=COVID19;' 'Trusted_Connection=yes;')
cursor = conn.cursor()

sql_str = "SELECT iso_code FROM iso_code_detail"

SQL_Query = pd.read_sql_query(sql_str, conn)

iso_codes = pd.DataFrame(SQL_Query, columns=['iso_code'])
iso_codes.sort_values(by='iso_code', inplace=True)
as_of_date = "2020-05-23"#datetime.today().strftime('%Y-%m-%d')

for index, row in iso_codes.iterrows():
    _filter = {"code": row['iso_code']}
    response = rq.post(url=url, data=js.dumps(_filter))
    has_response = list(js.loads(response.text)["date"]).__len__()

    if has_response == 0:
        print('no response')
        continue

    df = pd.DataFrame.from_dict(js.loads(response.text))

    after_as_of_date = df["date"] == as_of_date
    filtered_df = df.loc[after_as_of_date]
    print(filtered_df[['country', 'cases', 'date']])
    conn = po.connect('Driver={SQL Server};' 'Server=RUNAJ\INSTANCE2016;' 'Database=COVID19;' 'Trusted_Connection=yes;')
    cursor = conn.cursor()

    for index, row in filtered_df.iterrows():
        cursor.execute(
            "INSERT INTO covid_case_details (date,day,month,year,cases,deaths,country,code,population,cases_cum,deaths_cum) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            row['date'], row['day'], row['month'], row['year'], row['cases'], row['deaths'], row['country'],
            row['code'], row['population'], row['cases_cum'], row['deaths_cum'])
        conn.commit()

    cursor.close()
    conn.close()
