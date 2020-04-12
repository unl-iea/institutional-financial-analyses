# coding=utf-8

import pickle
import pandas as pd
import numpy as np
from user_functions import net_load_data
import pathlib

first_year = 2002
last_year = 2018

def ipeds_pickle(url, filespec, dtypes = 'object'):
    """ download ipeds data file at url and dump to pickle at filespec
        setting column name to lower and dropping imputation fields """
    print("\tReading {}...".format(url), end="", flush=True)
    df = net_load_data(url, types = dtypes)
    df.columns = df.columns.str.strip().str.lower()
    keepers = [col for col in df if not col.startswith('x')]
    df = df[keepers]

    with open(filespec, 'wb') as f:
        pickle.dump(df, f, pickle.HIGHEST_PROTOCOL)
    
    print('DONE.\n')

for year in range(first_year, last_year + 1):
    print('Downloading data for {}:'.format(year))
    try:
        # read hd
        ipeds_pickle('https://nces.ed.gov/ipeds/datacenter/data/hd{}.zip'.format(year),
                        pathlib.Path.cwd() / 'data/ipeds_hd_{}.pickle'.format(year),
                        dtypes = {'unitid': np.int32,
                                  'countycd': np.float32,
                                  'obereg': np.float32,
                                  'iclevel': np.float32,
                                  'control': np.float32,
                                  'hloffer': np.float32,
                                  'hdegofr1': np.float32,
                                  'ugoffer': np.float32,
                                  'groffer': np.float32,
                                  'deggrant': np.float32,
                                  'locale': np.float32,
                                  'newid': np.float32,
                                  'deathyr': np.float32,
                                  'cbsa': np.float32,
                                  'cbsatype': np.float32,
                                  'csa': np.float32,
                                  'longitud': np.float32,
                                  'latitude': np.float32,
                                  'openpubl': np.float32,
                                  'landgrnt': np.float32,
                                  'hbcu': np.float32,
                                  'hospital': np.float32,
                                  'medical': np.float32,
                                  'tribal': np.float32})

        # read ic
        ipeds_pickle('https://nces.ed.gov/ipeds/datacenter/data/ic{}.zip'.format(year),
                        pathlib.Path.cwd() / 'data/ipeds_ic_{}.pickle'.format(year),
                        dtypes = {'unitid': np.int32,
                                  'slo5': np.float32,
                                  'confno1': np.float32,
                                  'confno2': np.float32,
                                  'confno3': np.float32,
                                  'confno4': np.float32})

        # read ay charges
        ipeds_pickle('https://nces.ed.gov/ipeds/datacenter/data/ic{}_ay.zip'.format(year),
                        pathlib.Path.cwd() / 'data/ipeds_ic_{}_ay.pickle'.format(year))
    except Exception as e:
        print('ERROR.\nFile not downloaded properly.\n\n{}\n'.format(str(e)))
        break

print("\nAll Done!")
