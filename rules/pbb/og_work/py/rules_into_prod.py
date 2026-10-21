from pathlib import Path
from datetime import datetime as dt
from cli import cli
from file_inout import inout as io
import db.db as db
import db.queries as q

PY_DIR = Path(__file__).resolve().parent  # python root
BASE_DIR = PY_DIR.parent  # project_root
FTIME = dt.strftime(dt.now(), "%m%d%Y_%H%M%S")
OUT_DIR = Path(rf"{PY_DIR}/sqlout/rules").absolute()
OUT_DIR_NEW = Path(rf"{OUT_DIR}/{FTIME}").absolute()
SQL_L = Path(rf"{OUT_DIR}/rules_to_prod_ins_{FTIME}.sql").absolute()

i0 = Path(OUT_DIR_NEW) / (rf"ins_00_{FTIME}.sql")
i1 = Path(OUT_DIR_NEW) / (rf"ins_01_{FTIME}.sql")
i2 = Path(OUT_DIR_NEW) / (rf"ins_02_{FTIME}.sql")
i3 = Path(OUT_DIR_NEW) / (rf"ins_03_{FTIME}.sql")
outf_map = {
    "roralgs": i0,
    "rtvabrc": i1, "rtvpbgp": i1, "rtvpbcp": i1,
    "rbrabrc": i2,
    "rbrpgpt": i3, "rbrpbgp": i3, "rbrpbcp": i3, "rbrpbdr": i3, "rbrpell": i3
}

def main():
    args = cli.cli_args()

    if args.output_file:
        if not args.output_file.endswith(".sql"):
            outf = Path(OUT_DIR) / (args.output_file + ".sql")
        else: outf = Path(OUT_DIR) / (args.output_file)
    else: outf = SQL_L

    if not args.file_only:
        io.make_output_dir(OUT_DIR_NEW)
        outf = Path(OUT_DIR_NEW) / (f"ins_all_{FTIME}.sql")
    
    try: dbconn = db.connectToDB()
    except: raise ConnectionError("error connecting to db")

    DATASETS = []
    if args.rules_only:
        DATASETS.append(db.Dataset(q.rbrabrc))
    elif args.no_rules:
        DATASETS.append(db.Dataset(q.rtvpbcp))
        DATASETS.append(db.Dataset(q.rtvpbgp))
        DATASETS.append(db.Dataset(q.rtvabrc))
    else:
        DATASETS.append(db.Dataset(q.rtvpbgp))
        DATASETS.append(db.Dataset(q.rtvpbcp))
        DATASETS.append(db.Dataset(q.rtvabrc))
        DATASETS.append(db.Dataset(q.roralgs))
        DATASETS.append(db.Dataset(q.rbrpgpt))
        DATASETS.append(db.Dataset(q.rbrabrc))
        DATASETS.append(db.Dataset(q.rbrpell))
        DATASETS.append(db.Dataset(q.rbrpbdr))
        DATASETS.append(db.Dataset(q.rbrpbcp))
        DATASETS.append(db.Dataset(q.rbrpbgp))
        
    for ds in DATASETS:
        print(f"querying {ds.table}")
        
        try: cur = ds.exec_query(dbconn)
        except: raise BaseException("query failed")
        
        try:
            cols = db.fields_meta(cur.description)
            rows = cur.fetchall()
        except: raise BaseException(
            f"failed to get cursor description or fetchall from cursor for {ds.table}")
        
        try:
            if args.aidy:
                ins_data = db.vals_to_insert(cols, rows, aidy=args.aidy)
            else: 
                ins_data = db.vals_to_insert(cols, rows)
        except: raise BaseException(f"failed to get values to insert in {ds.table}")
        
        try:
            ts = 0 if ds.table == "FAISMGR.RBRABRC" else 4
            ins = ds.build_insert(ins_data, tabsize=ts)
        except: raise BaseException(f"failed to build insert statement for {ds.table}")
        
        try:
            if args.file_only:
                io.write_to_file(outf, ins)
                print(f"wrote output to {outf}")
            else:
                io.write_to_file(outf, ins)
                multi_outf = ""
                tbl = ds.table.lower().rpartition(".")[-1]
                if not args.tables:
                    multi_outf = outf_map[tbl]
                else:
                    multi_outf = Path(OUT_DIR_NEW) / (tbl + ".sql")
                    
                io.write_to_file(multi_outf, ins)
                print(f"wrote output to {outf} and {multi_outf}")
                
        except: raise BaseException(f"failed to write to file: {outf}")

if __name__ == "__main__":
    main()