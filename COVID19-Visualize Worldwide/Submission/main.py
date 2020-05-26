import pandas as pd
import pyodbc as po
import matplotlib.pyplot as plt
import tkinter as tk
from PIL import ImageTk, Image
from sklearn import linear_model
import datetime

root = tk.Tk()
root.title('COVID 19: Worldwide Situation')
root.iconbitmap('G:\\Business Intelligence\\Final Project\\corona_icons\\corona_zvd_1.ico')
image = ImageTk.PhotoImage(Image.open("G:\\Business Intelligence\\Final Project\\Corona.png"))
target_cases = type('entry', (object,), {})()
target_deaths = type('entry', (object,), {})()
mainWindow = tk.Canvas(root, width=430, height=400)
mainWindow.create_image(0, 0, anchor="nw", image=image)
mainWindow.pack()

mainWindow.create_text(200, 25, fill="white", text='COVID-19: Visualize Worldwide Situation', font="calibri 15 bold")
mainWindow.create_text(10, 50, anchor="nw", fill="white", text='Country:', font="calibri 12 bold")
mainWindow.create_text(10, 100, anchor="nw", fill="white", text='Data Options:', font="calibri 12 bold")
mainWindow.create_text(10, 150, anchor="nw", fill="white", text='Graph Type:', font="calibri 12 bold")
country = tk.Entry(root)

country = tk.StringVar()
country.set("")
col = ["Country"]
conn = po.connect('Driver={SQL Server};' 'Server=RUNAJ\INSTANCE2016;' 'Database=COVID19;' 'Trusted_Connection=yes;')
cursor = conn.cursor()

sql_str = "SELECT DISTINCT country FROM covid_case_details UNION ALL SELECT 'World' ORDER BY 1"
SQL_Query = pd.read_sql_query(sql_str, conn)
df = pd.DataFrame(SQL_Query, columns=['country'])

country_list = df['country'].values.tolist()

combo = tk.OptionMenu(root, country, "", *country_list)
combo.pack()
combo.place(relx=0.2, y=45)

y_axis = tk.StringVar()
y_axis.set("")
variable_options = ["Daily", "Total"]
combo = tk.OptionMenu(root, y_axis, "", *variable_options)
combo.pack()
combo.place(relx=0.27, y=95)

cm_graph_type = tk.StringVar()
cm_graph_type.set("")
graph_options = ["Line Graph", "Area Graph", "Bar Graph"]
combo_gt = tk.OptionMenu(root, cm_graph_type, "", *graph_options)
combo_gt.pack()
combo_gt.place(relx=0.25, y=145)

conn = po.connect('Driver={SQL Server};' 'Server=RUNAJ\INSTANCE2016;' 'Database=COVID19;' 'Trusted_Connection=yes;')
cursor = conn.cursor()

sql_str = "SELECT [date], cases, deaths, country, population, cases_cum, deaths_cum, DATEDIFF(DAY, '2019-12-31', [date]) day_count FROM covid_case_details" \
          " UNION ALL" \
          " SELECT [date], SUM(cases) cases, SUM(deaths) deaths, 'World' country, NULL population, SUM(cases_cum) cases_cum, SUM(deaths_cum) deaths_cum, DATEDIFF(DAY, '2019-12-31', [date]) day_count FROM covid_case_details" \
          " GROUP BY [date]" \
          " ORDER BY [date], country "

SQL_Query = pd.read_sql_query(sql_str, conn)

df = pd.DataFrame(SQL_Query,
                  columns=['date', 'cases', 'deaths', 'country', 'population', 'cases_cum', 'deaths_cum', 'day_count'])
df.sort_values(by='date', inplace=True)

variable1 = ""
variable2 = ""
graph_type = ""
y_label = ""
forecast_text = ""


def plot_graph():
    global country, variable1, variable2, y_label, graph_type, target_cases, target_deaths
    country_filter = country.get()

    filtered_df = df[(df.country == country_filter)]

    if y_axis.get() == 'Daily':
        variable1 = 'cases'
        variable2 = 'deaths'
        y_label = "Daily Cases and deaths"
    elif y_axis.get() == 'Total':
        variable1 = 'cases_cum'
        variable2 = 'deaths_cum'
        y_label = "Total Cases and deaths"

    if cm_graph_type.get() == 'Area Graph':
        graph_type = 'area'
    elif cm_graph_type.get() == 'Line Graph':
        graph_type = 'line'
    elif cm_graph_type.get() == 'Bar Graph':
        graph_type = 'bar'

    if forecast_text != "":
        variable1 = "cases"
        variable2 = "deaths"

    ax1 = filtered_df.plot(kind=graph_type, x='date', y=variable1, color='b', label="Total Cases")
    filtered_df.plot(kind=graph_type, x='date', y=variable2, color='r', ax=ax1, label="Total Deaths")
    ax1.legend()
    plt.xlabel("Date")

    total_days = filtered_df.loc[filtered_df['day_count'].idxmax()]['day_count']

    if forecast_text != "":
        tc = int(target_cases.get())
        td = int(target_deaths.get())
        plt.title(forecast_text)
        x = [0, total_days]
        y = [tc, tc]
        x1 = [0, total_days]
        y1 = [td, td]
        plt.plot(x, y, label="Target Daily Cases [" + str(tc) + "]", color="g")
        plt.plot(x1, y1, label="Target Daily Deaths [" + str(td) + "]", color="black")
        plt.legend()
    plt.ylabel(y_label)
    plt.show()


def btn_plot():
    global forecast_text
    forecast_text = ""
    if country.get() == "" or y_axis.get() == "" or cm_graph_type.get() == "":
        mainWindow.create_text(300, 50, anchor="nw", fill="red", text='              ')
        mainWindow.create_text(300, 50, anchor="nw", fill="red", text='Value missing!', font="calibri 12 bold")
        return

    plot_graph()


def btn_exit():
    root.destroy()


def btn_submit_click():
    global country, target_cases, target_deaths, forecast_text
    country_filter = country.get()

    if country_filter == "":
        country_filter = "Sweden"

    filtered_df = df[(df.country == country_filter)]

    x = filtered_df[['cases', 'deaths']]
    y = filtered_df[['day_count']]

    reg = linear_model.LinearRegression()
    reg.fit(x, y)
    x1 = int(target_cases.get())
    x2 = int(target_deaths.get())

    dict1 = {
        "cases": [x1],
        "deaths": [x2]
    }
    prediction_data = pd.DataFrame(dict1, columns=["cases", "deaths"])

    coef = reg.predict(prediction_data)
    output = int(coef[0][0])
    max_day =  df.loc[df['day_count'].idxmax()]['day_count']
    # print(max_day)
    # print(output)
    if max_day < output:
        days_left = int(output - max_day)
    else:
        days_left = int(max_day - output)

    # print(days_left)
    today = datetime.date.today()
    end_date = today + datetime.timedelta(days=days_left)

    forecast_text = "Country: " + country.get() + "|| Date: " + str(today) + "\n" \
                                                  "The target will be reached after " + str(
        int(days_left)) + " days from today, [" + str(end_date) + "]."

    # print(forecast_text)
    plot_graph()


def btn_forecast():
    global target_cases, target_deaths
    mainWindow.create_text(200, 250, anchor="nw", fill="white", text='Target Daily Cases:', font="calibri 10 bold")
    mainWindow.create_text(200, 280, anchor="nw", fill="white", text='Target Daily Deaths:', font="calibri 10 bold")
    target_cases = tk.Entry(root)
    mainWindow.create_window(355, 260, window=target_cases, width="100")
    target_deaths = tk.Entry(root)
    mainWindow.create_window(363, 288, window=target_deaths, width="100")
    btn_submit = tk.Button(text='Submit', command=btn_submit_click)
    mainWindow.create_window(380, 320, window=btn_submit)


btn_plot = tk.Button(text='        Plot            ', command=btn_plot)
mainWindow.create_window(250, 200, window=btn_plot)
btn_exit = tk.Button(text='        Exit            ', command=btn_exit)
mainWindow.create_window(350, 200, window=btn_exit)
btn_forecast = tk.Button(text='        Forecast            ', command=btn_forecast)
mainWindow.create_window(300, 230, window=btn_forecast)
root.mainloop()
# '''
