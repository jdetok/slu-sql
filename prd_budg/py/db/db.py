from dotenv import load_dotenv
import cx_Oracle
import os
from datetime import datetime
from file_inout import inout as io

# fields with these suffixes will be auto-filled on insert
IGNORE_FIELDS = ["_USER_ID", "_VERSION", "_SURROGATE_ID", "VPDI_CODE", "_DATA_ORIGIN"]
# keys in insert data dicts
val = "val"
fld = "fld"
lob = "lob"

# create connection to banner db (configs in .env)
def connectToDB() -> cx_Oracle.Connection:
    try:
        load_dotenv() # load DB env vars in .env
        user = os.environ['ORA_USER']
        pswd = os.environ['ORA_PASS']
        port = os.environ['ORA_PORT']
        host = os.environ['ORA_HOST']
        name = os.environ['ORA_NAME']
        conn_str = f"{user}/{pswd}@{host}:{port}/{name}"
        conn = cx_Oracle.connect(conn_str)
        return conn
    except Exception as e:
        print(e)
    
# create a Dataset object for each target table / query
class Dataset:
    def __init__(self, dataset):
        self.table = dataset["table"]
        self.query = dataset["query"]

    def exec_query(self, conn: cx_Oracle.Connection) -> cx_Oracle.Cursor:
        cur = conn.cursor()
        return cur.execute(self.query)
    
    def build_insert(self, ins_data, tabsize=4):
        if len(ins_data) < 1:
            raise ValueError("empty list passed to build_inserts()")
        
        t = "" if tabsize == 0 else (" " * tabsize)
        ins = f"-- insert {len(ins_data)} rows into {len(ins_data[0])} {self.table} fields\n"
        
        cols = io.fmt_join(get_vals_from_dicts(ins_data[0], fld), tab=tabsize)
        for row in ins_data:
            vals = io.fmt_join(get_vals_from_dicts(row, val), tab=tabsize, safe=False)
            ins += (
            f"INSERT INTO {self.table} (\n"
            f"{t}{cols}\n"
            f") VALUES (\n"
            f"{t}{vals}\n"
            f");\n\n"
        )
        return ins
    
    
def get_vals_from_dicts(t: tuple, k: str) -> tuple:
    vals = []
    for d in t:
        if d[lob]:
            vals.append(f"{d[k]}")
            continue
        vals.append(d[k])
    return tuple(vals)

# return arr of dicts with fetch info for each field
def fields_meta(description) -> tuple:
    fields = []
    for cur_desc in description:
        fields.append({
            "name": cur_desc[0],
            "db_type": cur_desc[1],
            "null_ok": cur_desc[-1]
        })
    return tuple(fields)

# pass a field name, return true if field should be ignored in building insert
def ignore_fld(fld_name: str) -> bool:
    for ignore_str in IGNORE_FIELDS:
        if ignore_str in fld_name:
            return True
    return False

# format vals to what they need to be for an input
def vals_to_insert(cols, rows_in, aidy=0) -> tuple:
    rows_out = []
    for row in rows_in:
        row_out = []
        for col_idx, v in enumerate(row):
            fld_name = cols[col_idx]["name"]
            if ignore_fld(fld_name):
                continue
            
            if aidy > 0 and "_AIDY_CODE" in fld_name:
                row_out.append({
                    fld: fld_name,
                    val: f"'{aidy}'",
                    lob: True
                })
                continue
            
            if isinstance(v, cx_Oracle.LOB):
                row_out.append({
                    fld: fld_name,
                    val: f"""q'[\n{v.read()}\n]'""",
                    # val: f"""'{v.read().replace("'", "''")}'""",
                    lob: True
                })
                continue
            if isinstance(v, str):
                row_out.append({
                    fld: fld_name,
                    val: f"'{v}'",
                    lob: False
                })
                continue
            if isinstance(v, int) or isinstance(v, float):
                row_out.append({
                    fld: fld_name,
                    val: f"{v}",
                    lob: False
                })
                continue
            if isinstance(v, datetime): # convert to string, then to ora date type
                str_dt = datetime.strftime(v, "%m/%d/%Y %H:%M:%S")
                row_out.append({
                    fld: fld_name,
                    val: f"TO_DATE('{str_dt}', 'MM/DD/YYYY HH24:MI:SS')",
                    lob: False
                })
                continue
            if v == None:
                if cols[col_idx]["null_ok"]:
                    row_out.append({
                        fld: fld_name,
                        val: "NULL",
                        lob: False
                })      
                else: raise ValueError(f"field {fld_name} null, needs a value")
            else: raise TypeError(f"unexpected type in fld {fld_name}: {type(v)}") 
        rows_out.append(row_out)         
    return rows_out