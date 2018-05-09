import os

import pandas as pd
import sqlite3
file = "chamado_ocorrencia1.csv"

csvFile = pd.read_csv(file, sep=';')
csvFile = csvFile.drop(0)
csvFile.head()

conn = sqlite3.connect("testee.db")
cur = conn.cursor()
csvFile.to_sql("historico", conn, if_exists="replace")

from flask import Flask, request
from flask_restful import Resource, Api
from sqlalchemy import create_engine
from json import dumps

#Create a engine for connecting to SQLite3.
#Assuming salaries.db is in your app root folder

e = create_engine('sqlite:///testee.db')

app = Flask(__name__)
api = Api(app)

class Solicitacao_Get(Resource):
    def get(self, solicitacao_id):
        #Connect to databse
        conn = e.connect()
        #Perform query and return JSON data
        query = conn.execute("select * from historico where SOLICITACAO='%s'"%solicitacao_id.upper())
        return {'result': [i[2:] for i in query.cursor.fetchall()],}

api.add_resource(Solicitacao_Get, '/solicitacao/<string:solicitacao_id>')

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)

