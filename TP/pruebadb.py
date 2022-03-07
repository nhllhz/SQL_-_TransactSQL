import pyodbc 
#
# Some other example server values are:
# server = 'localhost\sqlexpress' # for a named instance
# server = 'myserver,port' # to specify an alternate port
#
# Desde CMD ejecutar: py "pruebadb.py" # desde el path donde esté el archivo
#
# Crear el origen de datos ODBC
# Habilitar desde SQL Server el usuario 'sa' y la pasword
#
server = 'MYPC\SQLEXPRESS' # ejemplo
database = 'Ventas2' 
username = 'sa' 
password = 'admin' 
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
cursor = cnxn.cursor()

print("INSTRUCCIÓN SQL:")
sql = input()

#Sample select query
#cursor.execute("SELECT @@version;") 
cursor.execute(sql)
row = cursor.fetchone() 
while row: 
    print(row[0])
    row = cursor.fetchone()