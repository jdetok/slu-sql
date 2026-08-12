# Create insert statements for RORALGS
# reads excel with roralgs values at <FILE HERE> and creates an insert statement
# written by Justin DeKock 11/7/2025 

import sys
from pathlib import Path
from datetime import datetime as dt
from file_inout import inout

PY_DIR = Path(__file__).resolve().parent  # python root
BASE_DIR = PY_DIR.parent  # project_root

# timestamp string
FTIME = dt.strftime(dt.now(), "%m%d%Y_%H%M%S")

# files from local environment
EXL_L = Path(rf"{BASE_DIR}/roralgs/roralgs.xlsx").absolute() # may need to switch slashes
SQL_L = Path(rf"{PY_DIR}/sqlout/roralgs/roralgs_ins_{FTIME}.sql").absolute()
LOCAL = {"exl": EXL_L, "sql": SQL_L}

# files from network drive
T_DIR = rf"T:\Enrollment Retention Management\Student_Financial_Services\SYSTEMS\buddy_pb_sql_fall25\roralgs"
EXL_T = rf"{T_DIR}\roralgs_draft.xlsx"
SQL_T = rf"{T_DIR}\sql\roralgs_ins_{FTIME}.sql"
TDRIVE = {"exl": EXL_T, "sql": SQL_T}

# sheets to parse in excel file
# SHEETS = [
#     "1TUI_UG", "2FEE", "3HSM", "4COM", "5CAF", "6LIV", "7BS", "8TRS", "9MIS", 
#     "21BF", "22DF", "23PF", "24SF"
# ]
SHEETS = [
    "1TUI_MR", "1TUI_GR", "1TUI_PL", "1TUI_PM"
]
# formatting of sql output
COLS_PER_LINE = 5
VALS_PER_LINE = 10

# program entrypoint
def main():
    # print(f"{EXL_L}")
    env = LOCAL
    if len(sys.argv) > 1:
        match sys.argv[1]:
            case "t":
                env = TDRIVE
            
    # wb = open_xl(env["exl"])
    wb = inout.open_xl(env["exl"])
    
    for sheet in SHEETS:
        ws = wb[sheet]
        sh_content = inout.read_sheet(ws)
        data = parse_rows(sh_content)
        ins = build_insert_stmnt(data)
        if ins == "empty":
            continue
        inout.write_to_file(f"{env["sql"]}", 
            f"-- RORALGS INSERT ({len(sh_content['rows'])} rows) FOR SHEET: <{sheet}>\n{ins}\n\n")

# returns each row as a dict, with row number mapped to a dict with hdr mapped to the data
def parse_rows(content: dict[str, tuple[tuple]]) -> dict:
    row_data = dict()
    for ir, row in enumerate(content["rows"]):
        data = dict()
        for ic, hdr in enumerate(content["cols"]):
            data[hdr] = row[ic]
        row_data[ir + 1] = data
    return row_data
    
def chunk_arr(arr, n):
    for i in range(0, len(arr), n):
        yield arr[i:i+n]
    
# accept dict created in parse_rows, build insert statement string        
# keys are the column headers from excel sheet - AIDY_CODE, KEY_1..., AMOUNT
# COLUMNS MUST BE NAMED THIS WAY, THEY'RE USED TO BUILD RORALGS_KEY_X STYLE
# FIELD NAMES DYNAMICALLY
# get tuples of row strings - each contains a string to concat 
# to insert statement, represents one row of data being inserted
def build_insert_stmnt(data: dict) -> str:
    rows = build_row_strs(data)
    if len(rows) == 0:
        return "empty"
    cols = data[1].keys()
    return (
f"""INSERT INTO FAISMGR.RORALGS 
({join_to_charlimit([f'RORALGS_{col}' for col in cols])}) 
VALUES 
{',\n'.join(rows)};""")

# loop through data dictionary (spreadsheet data) and return a tuple of row strings
# to be concatenated to insert statement string
def build_row_strs(data: dict) -> tuple:
    rows = []
    for d in data.values():
        vals, skip = build_row_str(d)
        if skip:
            print(f"issue building row, skipping\n** row data: {d}")
            continue
        # rowstr = f"({'\n'.join(', '.join(chunk) for chunk in chunk_arr(vals, 8))})"
        rowstr = f"({join_to_charlimit(vals)})"
        rows.append(rowstr)
    return tuple(rows)

def build_row_str(d):
    skip = True
    vals = []
    for k, v in d.items():
        if str(k) == "AMT" and not str(v).isnumeric():
            return vals, skip
            # raise ValueError(f"passed non-numeric amount: {str(v)}")
        # cell is empty, insert NULL
        if v is None:
            vals.append("NULL")
        # value is numeric but not in the aid year column, append just the value
        elif str(v).isnumeric() and not 'AIDY' in str(k):
            vals.append(str(v))
        elif "'" in str(v):
            new_str = ""
            for char in str(v):
                apnd_char = char
                if char == "'":
                    apnd_char += "'"
                new_str += apnd_char
            vals.append((f"'{new_str}'"))
        # non numeric OR an aid year, append the value wrapped in ''
        else:
            vals.append(f"'{d[k]}'")
    return tuple(vals), not skip
 

# append tuple items to a string, but add a line break before a line reaches
# charlimit characters
def join_to_charlimit(arr: tuple, charlimit=80):
    lines = []
    current_line = ""
    for v in arr:
        # start with comma if in an existing line
        to_append = (", " if current_line else "") + f"{v}"
    
        # check whether appending the value will put the line over the charlimit
        if len(current_line) + len(to_append) > charlimit:
            lines.append(current_line + ",") # append line if so
            current_line = v # start new line with the value
            continue # move on to next value
        current_line += to_append # not over charlimit, append the value
    # append the last line
    if current_line: 
        lines.append(current_line)
    # return string with line breaks added
    return '\n'.join(lines) 
 
if __name__ == "__main__":
    main()