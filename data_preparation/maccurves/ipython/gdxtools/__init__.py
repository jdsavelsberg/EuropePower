from .GdxFile import GdxFile
import gams


def copy_symbol(name, source, target):
    """Copys symbols from source to target database
    Note: currently only works for parameters
    param name: <string> name of symbol to copy
    param source: <gams.GamsDatabase> with source data
    param target: <gams.GamsDatabase> target gdx database"""
    s_sym = source.get_symbol(name)
    
    # create a blank symbol in the target data base and copy values
    try:
        t_sym = target.add_parameter(name, s_sym.get_dimension(), s_sym.get_text())
    except gams.GamsException:
        # symbol already exists 
        t_sym = target.get_symbol(name)
        pass
                
    if not s_sym.copy_symbol(t_sym):
        raise ValueError("Could not copy GAMS Symbol")