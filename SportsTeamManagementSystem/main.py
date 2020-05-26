import wget as w
import tkinter as tk
from tkinter.ttk import *
from Teams import Teams
from mongodb import *
from tkinter.font import nametofont

root = tk.Tk()
root.title('Sports Team Management System')
root.iconbitmap('D:\SportsTeamManagementSystem\img.ico')
tree_view = type('tree_view', (object,), {})()
mainWindow = tk.Canvas(root, width=400, height=250)
mainWindow.pack()
call_from = 'i'
update_row_id = ''

lbl_title = tk.Label(root, text='Sports Team Management System')
lbl_title.config(font=('calibri', 20))
mainWindow.create_window(200, 25, window=lbl_title)

lbl_team_name = tk.Label(root, text='Team Name:')
lbl_team_name.config(font=('calibri', 10))
mainWindow.create_window(150, 75, window=lbl_team_name)
team_name = tk.Entry(root)
mainWindow.create_window(250, 75, window=team_name)

lbl_city = tk.Label(root, text='City:')
lbl_city.config(font=('calibri', 10))
mainWindow.create_window(150, 100, window=lbl_city)
team_city = tk.Entry(root)
mainWindow.create_window(250, 100, window=team_city)

lbl_num_player = tk.Label(root, text='No. of Players:')
lbl_num_player.config(font=('calibri', 10))
mainWindow.create_window(150, 125, window=lbl_num_player)
no_of_players = tk.Entry(root)
mainWindow.create_window(250, 125, window=no_of_players)

lbl_entry_fee = tk.Label(root, text='Entry Fee:')
lbl_entry_fee.config(font=('calibri', 10))
mainWindow.create_window(150, 150, window=lbl_entry_fee)

options = [
    "Paid",
    "Unpaid"
]
clicked = tk.StringVar()
clicked.set("Unpaid")

combo = OptionMenu(root, clicked, "", "Paid", "Unpaid")
combo.pack()
combo.place(relx=0.5, y=140, anchor='nw')

def save_team():
    global call_from
    entry_fee = False
    if clicked.get() == 'Paid':
        entry_fee = True

    if team_name.get() == '':
        lbl_error = tk.Label(root, text='Insert Data in Team Name!!', fg='red')
        lbl_error.config(font=('calibri', 10))
        mainWindow.create_window(200, 50, window=lbl_error)
        return

    if team_city.get() == '':
        lbl_error = tk.Label(root, text='                                                                          ')
        mainWindow.create_window(200, 50, window=lbl_error)
        lbl_error = tk.Label(root, text='Insert Data in Team City!!!', fg='red')
        lbl_error.config(font=('calibri', 10))
        mainWindow.create_window(200, 50, window=lbl_error)
        return

    if no_of_players.get() == '':
        lbl_error = tk.Label(root, text='                                                                          ')
        mainWindow.create_window(200, 50, window=lbl_error)
        lbl_error = tk.Label(root, text='Insert Data in Total Players!!', fg='red')
        lbl_error.config(font=('calibri', 10))
        mainWindow.create_window(200, 50, window=lbl_error)
        return

    new_team = Teams()
    new_team.set_name(team_name.get())
    new_team.set_city(team_city.get())
    new_team.set_total_players(no_of_players.get())
    new_team.set_entry_fee(entry_fee)
    team_name.delete(0, tk.END)
    team_city.delete(0, tk.END)
    no_of_players.delete(0, tk.END)
    clicked.set("Unpaid")

    if call_from == 'i':
        new_team.register_team()
    else:
        new_team.update_team(update_row_id)
        call_from = 'i'


    lbl_error = tk.Label(root, text='                                                                          ')
    mainWindow.create_window(200, 50, window=lbl_error)
    lbl_success = tk.Label(root, text='Data Saved Successfully!!!', fg='green')
    lbl_success.config(font=('calibri', 10))
    mainWindow.create_window(200, 175, window=lbl_success)
    retrive_team_data()
    load_table(tree_view)

def update_data():
    global call_from, update_row_id
    this_item = tree_view.focus()
    grid_data = tree_view.item(this_item)
    grid_row = grid_data['values']
    update_row_id = grid_row[4]
    new_team_name = grid_row[0]
    team_name.delete(0, tk.END)
    team_name.insert(0, new_team_name)
    new_team_city = grid_row[1]
    team_city.delete(0, tk.END)
    team_city.insert(0, new_team_city)
    new_no_of_players = grid_row[2]
    no_of_players.delete(0, tk.END)
    no_of_players.insert(0, new_no_of_players)
    new_entry_fee = grid_row[3]
    clicked.set(new_entry_fee)
    call_from = 'u'

def delete_data():
    this_item = tree_view.focus()
    grid_data = tree_view.item(this_item)
    grid_row = grid_data['values']
    row_id = grid_row[4]
    delete_team(row_id)
    load_table(tree_view)
    lbl_error = tk.Label(root, text='                                                                          ')
    mainWindow.create_window(300, 225, window=lbl_error)
    lbl_success = tk.Label(root, text='Data Deleted Successfully!!', fg='red')
    lbl_success.config(font=('calibri', 10))
    mainWindow.create_window(300, 225, window=lbl_success)

def gen_summary():
    summary_list = show_summary()
    summary_win = tk.Toplevel()
    summary_win.title('Summary Report')
    summary_win.iconbitmap('D:\SportsTeamManagementSystem\img.ico')

    nametofont("TkHeadingFont").configure(weight="bold")
    summary_tree_view = Treeview(summary_win)
    summary_tree_view.place(x=0, y=95)
    summary_tree_view['show'] = 'headings'
    summary_tree_view['columns'] = ('no_of_teams', 'total_fee_collected', 'remaining_fee')
    summary_tree_view.heading("#0", text='Team Details', anchor='w')
    summary_tree_view.column('#0', anchor='w')
    summary_tree_view.heading('no_of_teams', text='No. of Teams')
    summary_tree_view.column('no_of_teams', anchor='center', width=150)
    summary_tree_view.heading('total_fee_collected', text='Total Fee Collected')
    summary_tree_view.column('total_fee_collected', anchor='center', width=150)
    summary_tree_view.heading('remaining_fee', text='Remaining Teams to Pay (%)')
    summary_tree_view.column('remaining_fee', anchor='center', width=200)

    summary_tree_view.pack()
    summary_tree_view.insert('', 'end', text="", values=(summary_list[0], summary_list[1], str(summary_list[2]) + "%"))

def gen_regitration_history():
    summary_list = show_summary()
    summary_win = tk.Toplevel()
    summary_win.title('History Report')
    summary_win.iconbitmap('D:\SportsTeamManagementSystem\img.ico')

    nametofont("TkHeadingFont").configure(weight="bold")
    summary_tree_view = Treeview(summary_win)
    summary_tree_view.place(x=0, y=95)
    summary_tree_view['show'] = 'headings'
    summary_tree_view['columns'] = ('team_name', 'registered_date', 'days_since_registered')
    summary_tree_view.heading("#0", text='Team Details', anchor='w')
    summary_tree_view.column('#0', anchor='w')
    summary_tree_view.heading('team_name', text='Team Name')
    summary_tree_view.column('team_name', anchor='center', width=150)
    summary_tree_view.heading('registered_date', text='Registered Date')
    summary_tree_view.column('registered_date', anchor='center', width=150)
    summary_tree_view.heading('days_since_registered', text='Days Since Registered')
    summary_tree_view.column('days_since_registered', anchor='center', width=200)

    summary_tree_view.pack()
    team_data = get_team_registration_data()
    print(team_data)
    for i in team_data:
        r_date = i['registered_date'].date()
        summary_tree_view.insert('', 'end', text="", values=(i['name'], r_date, int(i['dateDifference']/86400000.00)))

def retrive_team_data():
    build_table()
    lbl_clear = tk.Label(root, text='                                                                          ')
    mainWindow.create_window(300, 225, window=lbl_clear)
    mainWindow.create_window(200, 50, window=lbl_clear)
    lbl_success = tk.Label(root, text='Data Deleted Successfully!!', fg='red')
    btn_update = tk.Button(text='Update', command=update_data)
    mainWindow.create_window(-24, 230, window=btn_update)
    btn_delete = tk.Button(text='Delete', command=delete_data)
    mainWindow.create_window(24, 230, window=btn_delete)
    btn_gen_report = tk.Button(text='Generate Report', command=gen_report)
    mainWindow.create_window(95, 230, window=btn_gen_report)
    btn_gen_summary = tk.Button(text='Summary Report', command=gen_summary)
    mainWindow.create_window(193, 230, window=btn_gen_summary)
    btn_gen_summary = tk.Button(text='Registration History Report', command=gen_regitration_history)
    mainWindow.create_window(320, 230, window=btn_gen_summary)

def build_table():
    global tree_view
    #tree_view.detach()

    if str(type(tree_view)) == "<class 'tkinter.ttk.Treeview'>":
        tree_view.detach()

    if str(type(tree_view)) == "<class '__main__.tree_view'>":
        tree_view = Treeview()
        nametofont("TkHeadingFont").configure(weight="bold")
        tree_view.place(x=0, y=95)
        tree_view['show'] = 'headings'
        tree_view['columns'] = ('team_name', 'team_city', 'no_of_players', 'entry_fee', 'id')
        tree_view.heading("#0", text='Team Details', anchor='w')
        tree_view.column('#0', anchor='w')
        tree_view.heading('team_name', text='Team Name')
        tree_view.column('team_name', anchor='center', width=150)
        tree_view.heading('team_city', text='City')
        tree_view.column('team_city', anchor='center', width=150)
        tree_view.heading('no_of_players', text='No. of Players')
        tree_view.column('no_of_players', anchor='center', width=100)
        tree_view.heading('entry_fee', text='Entry Fee')
        tree_view.column('entry_fee', anchor='center', width=100)
        tree_view.heading('id', text='ID')
        tree_view.column('id', anchor='center', width=100)

    tree_view.pack()

    load_table(tree_view)

def load_table(table_object):
    global tree_view
    filter_team_name = team_name.get()
    filter_city = team_city.get()
    filter_no_of_players = no_of_players.get()
    filter_entry_fee = clicked.get()
    filter_team_obj = Teams()
    filter_team_obj.set_name(filter_team_name)
    filter_team_obj.set_city(filter_city)
    filter_team_obj.set_total_players(filter_no_of_players)
    filter_team_obj.set_entry_fee(filter_entry_fee)

    team_data = get_team_data(filter_team_obj)
    #tree_view.detach()
    for row in tree_view.get_children():
        tree_view.delete(row)

    for i in team_data:
        entry_fee = 'Unpaid'
        if i['entry_fee']:
            entry_fee = 'Paid'

        table_object.insert('', 'end', text="", values=(i['name'], i['city'], i['total_players'], entry_fee, i['_id']))
        tree_view = table_object

def gen_report():
    report_str = 'Team Name,City,No. of Players,Entry Fee,Unique ID\n'

    for child in tree_view.get_children():
        report_str += str(tree_view.item(child)['values']).replace('[', '').replace(']', '').replace("'", '') + '\n'

    file = open('report.csv', 'w')
    file.write(report_str)

    lbl_success = tk.Label(root, text='Report Generated on [D:\SportsTeamManagementSystem]', fg='blue')
    lbl_success.config(font=('calibri', 10))
    mainWindow.create_window(225, 250, window=lbl_success)

def exit():
    root.destroy()
btn_save = tk.Button(text='  Save Data  ', command=save_team)
mainWindow.create_window(200, 200, window=btn_save)
btn_retrive = tk.Button(text='Refresh Data', command=retrive_team_data)
mainWindow.create_window(100, 200, window=btn_retrive)
btn_exit = tk.Button(text='      Exit      ', command=exit)
mainWindow.create_window(300, 200, window=btn_exit)
root.mainloop()