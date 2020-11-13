"""simple connection to the database"""

from mysql.connector import MySQLConnection, Error

def call_find_all_sp():
    try:
        conn = MySQLConnection(host='localhost',
                            user='root',
                            password='',
                            db='firstdb')

        cursor = conn.cursor()
        args = ['fuck you', 'ass hole pass', '']
        out = cursor.callproc('authenticate', args)
        print(out)

        # print out the result
        for result in cursor.stored_results():
            print(result.fetchall())

    except Error as e:
        print(e)

    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    call_find_all_sp()