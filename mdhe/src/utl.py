from datetime import datetime 

def file_date() -> str:
    return datetime.now().strftime("%Y%m%d")
        
def logf_date() -> str:
    return datetime.now().strftime('%m%d%y_%H%M%S')

def logtime() -> str:
    return datetime.now().strftime("%m/%d/%y %H:%M:%S |")

def fill(length: int, char=' ') -> str:
    return char * length

def fill_around(length: int, val: str, justify='left', char=' ') -> str:
    if justify not in ('left', 'right'): 
        raise ValueError(f'justify val must be "left" or "right": passed {justify}')
    
    if len(char) != 1: 
        raise ValueError(f'passed char "{char}" must be exactly one character')
    
    if len(val) > length:
        raise ValueError(f'field length ({length}) must be greater than length of passed val "{val}": ({len(val)})')
    
    filled = ''
    to_fill = length - len(val)        
    
    if justify == 'left':
        filled = val + (char * to_fill)
    elif justify == 'right':
        filled = (char * to_fill) + val
        
    return filled