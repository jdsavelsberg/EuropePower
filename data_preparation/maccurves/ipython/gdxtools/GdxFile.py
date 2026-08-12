import gams
import os
import shutil
import atexit
import tempfile
import pandas as pd

import numpy as np
import collections
import sys
if sys.version_info[0] > 2:
    from builtins import str


class GdxFile(object):
    """Class for more convient gdx file handling"""
    
    def __init__(self, gdx):
        """ Constructor 
        :param gdx: <gams.GamsDatabase or string> underyling GamsDatabase or path to database
                In case a path is provided, workspace is automatically determined
        """
        self.filename = None
        if isinstance(gdx, str):
            # create temporary workspace directory and then the gdx database
            tmp_dir = tempfile.TemporaryDirectory()
            atexit.register(shutil.rmtree, tmp_dir.name)
            ws = gams.GamsWorkspace(tmp_dir.name)
            self.filename = os.path.abspath(gdx)
            if os.path.isfile(self.filename): 
                self.gdx = ws.add_database_from_gdx(self.filename)
            else:
                self.gdx = ws.add_database()
        else:
            self.gdx = gdx 
            
        self.symbols = [i.name for i in self.gdx]
        self.number_symbols = self.gdx.number_symbols
        
        @property
        def workspace(self):
            return self.gdx.workspace
           
    def save(self, fn=None):
        """Save gdx file
        :param fn: <string> file name
            Note that relative paths are interpreted relative 
            to Python working directory (not gams working directory)
        """  
        if fn is None:
            fn = self.filename
        if fn is None:
            raise Exception("No file name provided. Please specify file name")
        self.gdx.export(os.path.abspath(fn))
           
    def __len__(self):
        return self.number_symbols
    
    def __contains__(self, item):
        return item in self.symbols
    
    def __getitem__(self, key):
        return self.get_symbol(key)
        
    def __del__(self):
        # also free up the underlying database
        del self.gdx
        
    def add_set(self, values, name, text="", append=False, overwrite=False):
        """Adds sets to gdx database. If an existing symbol is passed, the symbol can be extended (append=True) or created new
        :param values: <list> of values
        :param gdx: <gams.GamsDatabase> in which values are inserted ()
        :param symbol: <gams.GamsSet> of existing gams set
        :param text: <string> explanatory string
        :param append: <boolean> if true values are append to symbol else existing records are cleared
        :param overwrite: <boolean> if true existing symbol is overwritten or appended, else error is thrown if symbol alread exists
        :return: <gams.GamsSet>
        """
        try:
            symbol = self.gdx.get_symbol(name)
            if not overwrite:
                raise ValueError("Symbol already exists. Set override=True to re-create of append values")
        except gams.GamsException:
            # get dimension
            dim = 1
            if isinstance(values[0], collections.Iterable) and (not isinstance(values[0], str)):
                dim = len(values[0])
            # create symbol
            symbol =  self.gdx.add_set(name, dim, text)

        # add records
        if append == False:
            symbol.clear()
        for v in values:
            if symbol.dimension == 1:
                symbol.merge_record(str(v))
            else:
                symbol.merge_record(list(map(str,v)))

    def add_parameter(self, values, name, text="", append=False, overwrite=False):
        """Adds sets to gdx database. If an existing symbol is passed, the symbol can be extended (append=True) or created new
        :param values: <dict set: value> parameter added
                    <numeric> scalar is added
        :param gdx: <gams.GamsDatabase> in which values are inserted ()
        :param symbol: <gams.GamsSet> of existing gams set
        :param text: <string> explanatory string
        :param append: <boolean> if true values are append to symbol else existing records are cleared
        :param overwrite: <boolean> if true existing symbol is overwritten or appended, else error is thrown if symbol alread exists
        :return: <gams.GamsSet>
        """
        try:
            symbol = self.gdx.get_symbol(name)
            if not overwrite:
                raise ValueError("Symbol already exists. Set override=True to re-create of append values")
        except gams.GamsException:
            # get dimension
            dim = 1
            # check for scalar case
            if isinstance(values, (float, int, np.int, np.float)):
                dim=0
            # more dimensional case
            elif isinstance(list(values.keys())[0], collections.Iterable) and (not isinstance(list(values.keys())[0], str)):
                dim = len(list(values.keys())[0])
            # create symbol
            symbol = self.gdx.add_parameter(name, dim, text)

        # add records
        if append == False:
            symbol.clear()
        # scalar case
        if symbol.dimension == 0:
            symbol.add_record().value = values
        # parameter case
        else:
            for k, v in values.items():
                # one dimensional
                if symbol.dimension == 1:
                    symbol.merge_record(str(k)).value = v
                # multi dimensional
                else:
                    symbol.merge_record(list(map(str,k))).value = v

    def get_symbol(self, name, col_names=None, kind="value"):
        """Wrapper around to gams.GamsDatabase.get_symbol method that returns a pandas series.
        :param db: <gams.GamsDatabase> data origin
        :param name: <string> name of the symbol
        :param col_names: [<string>] Column names for dimensions
        :param kind: <string> kind of value to return ("value", "level", "marginal",
                                                        "lower", "upper", "scale" only for equations)
        :return: (x) IF SET: <list>
                    ELSE:  <float> for scalar values; <pd.Series> for remaining with values as entries
                                    and dimensions as index """
        sym = self.gdx.get_symbol(name)
        n_dim = sym.dimension
        text = sym.text

        # prepare column names, if not provided use gams names
        if col_names is None:
            col_names_ = sym.get_domains_as_strings()
            # ensure that we do no have duplicated column names from universial set
            count = 0
            col_names = []
            for c in col_names_:
                if c == "*":
                    if count > 0:
                        col_names.append("*%d" % count)
                        continue
                    count += 1
                col_names.append(c)                        

        # VARIABLES
        if isinstance(sym, gams.database.GamsVariable) or isinstance(sym, gams.database.GamsEquation):
            if kind == "value":
                kind = "level"
            # in case of scalar return single value
            if n_dim == 0:
                return getattr(sym.find_record(), kind)
            else: # return a dataframe
                vals = [i.keys + [getattr(i, kind)] for i in sym]
                col_names += ["Value"]

        # PARAMETERS
        elif isinstance(sym, gams.database.GamsParameter):
            if n_dim == 0:
                return sym.find_record().get_value()
            else:
                vals = [i.keys + [getattr(i, kind)] for i in sym]
                col_names += ["Value"]

        # SETS
        elif isinstance(sym, gams.database.GamsSet):
            if n_dim == 1:
                return [i.keys[0]  for i in sym]
            else:
                return [tuple(i.keys)  for i in sym]

        # create and return dataframe
        df = pd.DataFrame(vals, columns=col_names).set_index(col_names[:n_dim])
        return df["Value"]



