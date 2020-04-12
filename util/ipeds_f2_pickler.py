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
    df = df[keepers]  # .astype(np.float32)
    df['unitid'] = df.unitid.astype(np.int32)

    with open(filespec, 'wb') as f:
        pickle.dump(df, f, pickle.HIGHEST_PROTOCOL)
    
    print('DONE.\n')

for year in range(first_year, last_year + 1):
    print('Downloading data for {}:'.format(year))
    yr_str = f'{str(year-1)[2:]}{str(year)[2:]}'
    
    try:
        # read hd
        ipeds_pickle(f'https://nces.ed.gov/ipeds/datacenter/data/f{yr_str}_f2.zip',
                        pathlib.Path.cwd() / 'data/ipeds_f2_{}.pickle'.format(year),
                        dtypes = 'object')

    except Exception as e:
        print('ERROR.\nFile not downloaded properly.\n\n{}\n'.format(str(e)))
        break

print("\nAll Done!")
