#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Created on Sat Mar 23 19:42:57 2019
@author: jasoncasey
"""
import keyring
from sqlalchemy import create_engine, Table, MetaData
import psycopg2
from io import BytesIO, StringIO
from zipfile import ZipFile
from urllib.request import urlopen
import pandas as pd


# item_recode maps labels on to coded columns
def item_recode(col, codings):
    # df.replace({colname: codings})
    answer = col.map(codings, na_action = "ignore") 
    
    return(answer)

def fix_cols(data):
    data.columns = [colname.lower() for colname in list(data.columns.values)]
    return(data)


def fix_number(col):
    try:
        col = col.str.replace("^\\.$", "")
        answer = pd.to_numeric(col.str.replace("[^0-9\\.\\-]", ""), errors = "coerce")
        # answer = pd.to_numeric(col, errors = "coerce")
    except Exception as e:
        print(str(e))
        return(str(e))
    
    return(answer)

def make_proportion(col):
    """ turn an integer column into a decimal proportion. """
    answer = col / 100
    return(answer)

def get_filename(file_list):
    """ find csv file from IPEDS download.  If a revised file exists ("_rv"), return
        that, otherwise, return the csv."""
    match = [s for s in file_list if "_rv" in s]
    answer = file_list[0]
    if len(match) > 0:
        answer = match[0]
    return(answer)

def net_load_info(url):
    """ return the file list from a zip file downloaded from a URL. """
    resp = urlopen(url)
    zipfile = ZipFile(BytesIO(resp.read()))
    files = zipfile.namelist()
    return(files)

def net_load_data(url, types = "object"):
    """ load a csv from an IPEDS zip at the specified URL.  use get_filename() to
        get the most recent revision.  Returns a pandas DataFrame. """
    with urlopen(url) as resp:
        zipfile = ZipFile(BytesIO(resp.read()))
        file_name = get_filename(zipfile.namelist())
        with zipfile.open(file_name) as data_file:
            answer = pd.read_csv(data_file,
                                 dtype = types,
                                 na_values = '.',
                                 index_col = False,
                                 low_memory = False,
                                 encoding = "iso-8859-1")

    return(answer)

def get_engine(db_name):
    answer = create_engine(r"postgres+psycopg2://{}:{}@localhost:5432/{}".format("jason",
                                                             keyring.get_password("localhost", "jason"),
                                                             db_name)
                           )
    return(answer)







def insert_to_db(df, db, table):
    username = input("User ID: ")
    
    sio = StringIO()
    sio.write(df.to_csv(index=None, header=None))  # Write the Pandas DataFrame as a csv to the buffer
    sio.seek(0)  # Be sure to reset the position to the start of the stream
    
    try:
        con = psycopg2.connect(user = username,
                         password = keyring.get_password(db, username),
                         host = "127.0.0.1",
                         port = "5432",
                         database = db)
        # Copy the string buffer to the database, as if it were an actual file
        with con.cursor() as c:
            c.copy_from(sio, table, columns = df.columns, sep=',')
        con.commit()
    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to PostgreSQL", error)
    finally:
        #closing database connection.
        if(con):
            # cursor.close()
            con.close()



def read_from_db(db, query):
    username = input("User ID: ")
    # dat = sqlio.read_sql_query(sql, conn)
    
    try:
        con = psycopg2.connect(user = username,
                         password = keyring.get_password(db, username),
                         host = "127.0.0.1",
                         port = "5432",
                         database = db)
        # cursor = con.cursor()
        # cursor.execute(query)
        df = pd.read_sql(query, con)
    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to PostgreSQL", error)
    finally:
        #closing database connection.
        if(con):
            # cursor.close()
            con.close()
    
    return(df)

# def get_engine(db_name):
#     answer = create_engine(r"mssql+pyodbc://{}:{}@{}".format(keyring.get_password("nu_warehouse_id", "token"),
#                                                              keyring.get_password("nu_warehouse_secret", "token"),
#                                                              db_name),
#                            legacy_schema_aliasing = True
#                            )
#     return answer