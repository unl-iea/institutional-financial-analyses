# coding=utf-8

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

import pyodbc
import keyring

# engine for making connections to db
engine = create_engine(r"mssql+pyodbc://{}:{}@{}".format(keyring.get_password("nu_warehouse_id", "token"),
                                                         keyring.get_password("nu_warehouse_secret", "token"),
                                                         "unl_ir"),
                        legacy_schema_aliasing = True)

# ms sql server using integrated security
# engine = create_engine(r'mssql+pyodbc://{}/{}?driver=SQL+Server+Native+Client+11.0?trusted_connection=yes'.format('EVC-GTW44M2\\SQLEXPRESS',
#                                                                                                                   'nsf'))

Session = sessionmaker(bind = engine)

Base = declarative_base()