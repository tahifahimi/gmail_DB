"""author : Tahere Fahimi 9539045
    final database project
    2020"""

import tkinter as tk
from tkinter import scrolledtext, messagebox
from mysql.connector import MySQLConnection
from tkinter import *

"""part 0 : initiate the connection"""
conn = MySQLConnection(host='localhost',
                               user='root',
                               password='',
                               db='firstdb')
cursor = conn.cursor()


"""call authentication function and if output was correct close the page"""
def authentication_button():
    try:
        data = []
        data.append(username.get())
        data.append(password.get())
        data.append('')
        out = cursor.callproc('authenticate', data)
        print(len(out))
        print(out[2])
        if out[2] == "done":
            conn.commit()
            entering.destroy()
    except:
        messagebox.showinfo('error', "error in authentication! enter correct username and password")


""" initialize new user to the system"""
def register_button():
    try:
        reg = []
        reg.append(uname.get())
        reg.append(p.get())
        reg.append(nec_phone.get())
        reg.append(fname.get())
        reg.append(lname.get())
        reg.append(address.get())
        reg.append(nickname.get())
        reg.append(phone.get())
        reg.append(birthdate.get())
        reg.append(id.get())
        reg.append('')
        out = cursor.callproc('register', reg)
        if out[10] == "done":
            conn.commit()
            entering.destroy()
        elif out[10]=="password is short":
            messagebox.showinfo('error', "password is short")
        elif out[10]=="little username":
            messagebox.showinfo('error', "little username")
        else:
            messagebox.showinfo('error', "repeated username")
    except:
        messagebox.showinfo('error', "enter in entering")
        print("Oops! Something wrong")


"""part 1: entering part ---> before using the system, you should enter to system"""
entering = tk.Tk()
"""authentication  part"""
tk.Label(entering, text="authentication").grid(column=0, row=0)
tk.Label(entering, text="username").grid(column=0, row=1)
username = tk.Entry(entering, width=10)
username.grid(column=1, row=1)
tk.Label(entering, text="password").grid(column=0, row=2)
password = tk.Entry(entering, width=10)
password.grid(column=1, row=2)
btn = tk.Button(entering, text="Click Me", command=authentication_button)
btn.grid(column=0, row=3)
"""register  part"""
tk.Label(entering, text="register").grid(column=2, row=0)
tk.Label(entering, text="username").grid(column=2, row=1)
uname = tk.Entry(entering, width=10)
uname.grid(column=3, row=1)
tk.Label(entering, text="password").grid(column=2, row=2)
p = tk.Entry(entering, width=10)
p.grid(column=3, row=2)
tk.Label(entering, text="nec_phone").grid(column=2, row=3)
nec_phone = tk.Entry(entering, width=10)
nec_phone.grid(column=3, row=3)
tk.Label(entering, text="fname").grid(column=2, row=4)
fname = tk.Entry(entering, width=10)
fname.grid(column=3, row=4)
tk.Label(entering, text="lname").grid(column=2, row=5)
lname = tk.Entry(entering, width=10)
lname.grid(column=3, row=5)
tk.Label(entering, text="address").grid(column=2, row=6)
address = tk.Entry(entering, width=10)
address.grid(column=3, row=6)
tk.Label(entering, text="nickname").grid(column=2, row=7)
nickname = tk.Entry(entering, width=10)
nickname.grid(column=3, row=7)
tk.Label(entering, text="phone").grid(column=2, row=8)
phone = tk.Entry(entering, width=10)
phone.grid(column=3, row=8)
tk.Label(entering, text="birthdate").grid(column=2, row=9)
birthdate = tk.Entry(entering, width=10)
birthdate.grid(column=3, row=9)
tk.Label(entering, text="id").grid(column=2, row=10)
id = tk.Entry(entering, width=10)
id.grid(column=3, row=10)
registerButton = tk.Button(entering, text="register Me", command=register_button)
registerButton.grid(column=2, row=11)

entering.wm_geometry("400x400")
entering.mainloop()


"""show inbox of the current user"""
def show_inbox():
    try:
        data = []
        data.append(5)
        data.append(int(page_number.get()))
        # data.append(1)
        print(data)
        cursor.callproc('inbox', data)
        for result in cursor.stored_results():
            print(result.fetchall())
        conn.commit()
    except:
        print("error in inbox")


def send_box():
    try:
        temp = tk.Tk()
        text = scrolledtext.ScrolledText(temp, width=40, height=40)
        text.grid(column=1, row=2)

        data = []
        data.append(5)
        data.append(page_num.get())
        cursor.callproc('send_box', data)
        for result in cursor.stored_results():
            d = result.fetchall()
            text.insert(INSERT, d)
        temp.wm_geometry("400x400")
        temp.mainloop()
        conn.commit()
    except:
        print("error in inbox")


def sending(sub, body, send_page, rec1, rec2, rec3, cc1, cc2, cc3):
    try:
        data = []
        data.append(sub.get())
        data.append(body.get())
        data.append(0)
        reciever = []
        r1 = rec1.get()
        re1 = ""
        re2 = ""
        re3 = ""
        out = cursor.callproc('send_email', data)
        print("the send _email: ", out)
        if r1 != '':
            re1 = cursor.callproc('insert_reciever',[out[2], r1, ''])
            print(re1)
        r2 = rec2.get()
        if r2!= '':
            re2 = cursor.callproc('insert_reciever',[out[2], r2, ''])
        r3 = rec3.get()
        if r3!='':
            re3 = cursor.callproc('insert_reciever',[out[2], r3, ''])
        if re1[2] == re2[2] == re3[2] == "error":
            messagebox.showinfo('error', "no valid reciver")

        c1 = cc1.get()
        if c1 != '':
            out_c1 = cursor.callproc('insert_cc',[out[2], c1, ''])
        c2 = cc2.get()
        if c2 != '':
            out_c1 = cursor.callproc('insert_cc', [out[2], c2, ''])
        c3 = cc3.get()
        if c3 != '':
            out_c1 = cursor.callproc('insert_cc', [out[2], c3, ''])

        print(out)
        if out[2] != 0:
            conn.commit()
            send_page.destroy()
        else:
            print("error in sending email")
    except:
        print("error in sending")


def send_mail():
    # create new page and send email
    send_page = tk.Tk()
    tk.Label(send_page, text="subject").grid(column=1, row=2)
    sub = tk.Entry(send_page, width=10)
    sub.grid(column=1, row=3)
    tk.Label(send_page, text="body").grid(column=2, row=2)
    body = tk.Entry(send_page, width=10)
    body.grid(column=2, row=3)

    tk.Label(send_page, text="reciever1").grid(column=3, row=2)
    rec1 = tk.Entry(send_page, width=10)
    rec1.grid(column=3, row=3)
    tk.Label(send_page, text="reciever2").grid(column=4, row=2)
    rec2 = tk.Entry(send_page, width=10)
    rec2.grid(column=4, row=3)
    tk.Label(send_page, text="reciever3").grid(column=5, row=2)
    rec3 = tk.Entry(send_page, width=10)
    rec3.grid(column=5, row=3)
    tk.Label(send_page, text="cc1").grid(column=6, row=2)
    cc1 = tk.Entry(send_page, width=10)
    cc1.grid(column=6, row=3)
    tk.Label(send_page, text="cc2").grid(column=7, row=2)
    cc2 = tk.Entry(send_page, width=10)
    cc2.grid(column=7, row=3)
    tk.Label(send_page, text="cc3").grid(column=8, row=2)
    cc3 = tk.Entry(send_page, width=10)
    cc3.grid(column=8, row=3)

    ok_butt = tk.Button(send_page, text="send", command=lambda : sending(sub, body, send_page, rec1, rec2, rec3, cc1, cc2, cc3))
    ok_butt.grid(column=0, row=3)

    send_page.wm_geometry("400x400")
    send_page.mainloop()


""" show current user notifications ---> paging!!!!!!!!!!!!!"""
def current_user_notif():
    notif_page = tk.Tk()
    text = scrolledtext.ScrolledText(notif_page, width=40, height=40)
    text.grid(column=1, row=2)
    try:
        out = cursor.callproc('current_user_notifs')
        print(out)
        for result in cursor.stored_results():
            # print(result.fetchall()[0][0])
            data = result.fetchall()[0][0]
            text.insert(INSERT, data)
    except:
        print("error in current user notifs")
    notif_page.wm_geometry("400x400")
    notif_page.mainloop()


def get_another_user_info(another):
    info_page = tk.Tk()
    text = scrolledtext.ScrolledText(info_page, width=40, height=40)
    text.grid(column=1, row=2)
    try:
        out = cursor.callproc('get_another_user_info', [another.get(), ''])
        print(out)
        if out[1]=="user not exist":
            messagebox.showinfo('error', "user not exist! enter correct username")
        else:
            for result in cursor.stored_results():
                # print(result.fetchall()[0][0])
                data = result.fetchall()
                print(data)
                text.insert(INSERT, "username : " + data[0][0] + "\n")
                text.insert(INSERT, "fname : " + data[0][1] + "\n")
                text.insert(INSERT, "lname : " + data[0][2] + "\n")
                text.insert(INSERT, "address : " + data[0][3] + "\n")
                text.insert(INSERT, "nickname : " + data[0][4] + "\n")
                text.insert(INSERT, "phone no: : " + data[0][5] + "\n")
                text.insert(INSERT, "birthdate: : " + str(data[0][7]) + "\n")
                text.insert(INSERT, "id : " + str(data[0][8]) + "\n")
        conn.commit()
    except:
        print("error in another user info")
    info_page.wm_geometry("400x400")
    info_page.mainloop()


def edit(edit_page, p, nec_phone, fname, lname, address, nickname, phone, birthdate, id, ac):
    data = []
    data.append(p.get())
    data.append(nec_phone.get())
    data.append(fname.get())
    data.append(lname.get())
    data.append(address.get())
    data.append(nickname.get())
    data.append(phone.get())
    data.append(birthdate.get())
    data.append(id.get())
    data.append(ac.get())
    data.append('')
    try:
        out = cursor.callproc('change_info', data)
        print(out)
        if out[10] == "changes Done":
            messagebox.showinfo('Done', out[10])
            conn.commit()
            edit_page.destroy()
        else:
            messagebox.showinfo('error', out[10])
    except:
        print("error in current user notifs")


def edit_information():
    edit_page = tk.Tk()
    tk.Label(edit_page, text="password").grid(column=2, row=2)
    p = tk.Entry(edit_page, width=10)
    p.grid(column=3, row=2)
    tk.Label(edit_page, text="nec_phone").grid(column=2, row=3)
    nec_phone = tk.Entry(edit_page, width=10)
    nec_phone.grid(column=3, row=3)
    tk.Label(edit_page, text="fname").grid(column=2, row=4)
    fname = tk.Entry(edit_page, width=10)
    fname.grid(column=3, row=4)
    tk.Label(edit_page, text="lname").grid(column=2, row=5)
    lname = tk.Entry(edit_page, width=10)
    lname.grid(column=3, row=5)
    tk.Label(edit_page, text="address").grid(column=2, row=6)
    address = tk.Entry(edit_page, width=10)
    address.grid(column=3, row=6)
    tk.Label(edit_page, text="nickname").grid(column=2, row=7)
    nickname = tk.Entry(edit_page, width=10)
    nickname.grid(column=3, row=7)

    tk.Label(edit_page, text="phone").grid(column=2, row=8)
    phone = tk.Entry(edit_page, width=10)
    phone.grid(column=3, row=8)

    tk.Label(edit_page, text="birthdate").grid(column=2, row=9)
    birthdate = tk.Entry(edit_page, width=10)
    birthdate.grid(column=3, row=9)

    tk.Label(edit_page, text="id").grid(column=2, row=10)
    id = tk.Entry(edit_page, width=10)
    id.grid(column=3, row=10)

    tk.Label(edit_page, text="access to all ").grid(column=2, row=11)
    ac = tk.Entry(edit_page, width=10)
    ac.grid(column=3, row=11)

    confirmButton = tk.Button(edit_page, text="Click Me", command=lambda : edit(edit_page, p, nec_phone, fname, lname, address, nickname, phone, birthdate, id, ac))
    confirmButton.grid(column=2, row=11)

    edit_page.wm_geometry("400x400")
    edit_page.mainloop()


def delete_account():
    try:
        out = cursor.callproc('change_info', ['',])
        print(out)
        if out[0] == "Done":
            messagebox.showinfo('Done', out[0])
            conn.commit()
        else:
            messagebox.showinfo('error', out[0])
    except:
        print("error deleting account")


def read_email(email_id):
    try:
        out = cursor.callproc('read_email', [int(email_id.get()), ''])
        if out[1]=="readed":
            messagebox.showinfo('message readed', out[1])
            conn.commit()
        else:
            messagebox.showinfo('error', out[1])
    except:
        print("error in reading an email")

def delete_email(email_id):
    try:
        out = cursor.callproc('delete_email', [int(email_id.get()), ''])
        if out[1] == 'deleted':
            messagebox.showinfo('message deleted : ', out[1])
            conn.commit()
        else:
            messagebox.showinfo('error', out[1])
    except:
        print("error in deleting an email")


def get_currentuser_info(text):
    try:
        out = cursor.callproc('get_all_info')
        print(out)
        for result in cursor.stored_results():
            # print(result.fetchall()[0][0])
            data = result.fetchall()
            print(len(data[0]))
            text.insert(INSERT, "username : "+data[0][0]+"\n")
            text.insert(INSERT, "fname : "+data[0][1]+"\n")
            text.insert(INSERT, "lname : "+data[0][2]+"\n")
            text.insert(INSERT, "address : "+data[0][3]+"\n")
            text.insert(INSERT, "nickname : "+data[0][4]+"\n")
            text.insert(INSERT, "phone no: : "+data[0][5]+"\n")
            text.insert(INSERT, "birthdate: : "+str(data[0][6])+"\n")
            text.insert(INSERT, "id : "+data[0][7]+"\n")
            text.insert(INSERT, "password : "+data[0][8]+"\n")
            text.insert(INSERT, "account time: "+data[0][9]+"\n")

        conn.commit()
    except:
        print("error in getting user  information")


"""all the function of the email can be accessible in here"""
main_page = tk.Tk()
inbox_button = tk.Button(main_page, text="inbox", command=show_inbox)
inbox_button.grid(column=0, row=0)
tk.Label(main_page, text="page number: ").grid(column=1, row=0)
page_number = tk.Entry(main_page, width=10)
page_number.grid(column=2, row=0)

sendbox_butt = tk.Button(main_page, text="send box", command=send_box)
sendbox_butt.grid(column=0, row=2)
tk.Label(main_page, text="page number: ").grid(column=1, row=2)
page_num = tk.Entry(main_page, width=10)
page_num.grid(column=2, row=2)

notif_butt = tk.Button(main_page, text="show notifs", command=current_user_notif)
notif_butt.grid(column=0, row=3)

another = tk.Entry(main_page, width=10)
getinfo_butt = tk.Button(main_page, text="get information", command=lambda: get_another_user_info(another))
getinfo_butt.grid(column=0, row=4)
tk.Label(main_page, text="other user:").grid(column=1, row=4)
another.grid(column=2, row=4)

editinfo_butt = tk.Button(main_page, text="edit information", command=edit_information)
editinfo_butt.grid(column=0, row=5)

delete_button = tk.Button(main_page, text="delete account", command=delete_account)
delete_button.grid(column=0, row=6)

primary_button = tk.Button(main_page, text="new email", command=send_mail)
primary_button.grid(column=0, row=7)

email_id = tk.Entry(main_page, width=10)
read_button = tk.Button(main_page, text="read email", command=lambda: read_email(email_id))
read_button.grid(column=0, row=8)
tk.Label(main_page, text="email id :").grid(column=1, row=8)
email_id.grid(column=2, row=8)

email_id2 = tk.Entry(main_page, width=10)
del_button = tk.Button(main_page, text="delete email", command=lambda: delete_email(email_id2))
del_button.grid(column=0, row=9)
tk.Label(main_page, text="email id").grid(column=1, row=9)
email_id2.grid(column=2, row=9)

te = scrolledtext.ScrolledText(main_page, width=40, height=40)
currino_button = tk.Button(main_page, text="get current user information", command=lambda : get_currentuser_info(te))
currino_button.grid(column=0, row=10)
te.grid(row=11)

main_page.wm_geometry("800x800")
main_page.mainloop()