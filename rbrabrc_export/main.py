# run a query that selects all SQL rules in the RBRABRC table, write each sequence from each rule to a .sql file

from dotenv import load_dotenv
from datetime import datetime
from pathlib import Path
# import cx_Oracle
import oracledb as cx_Oracle
cx_Oracle.init_oracle_client(lib_dir="/Users/dekockjt/oracle/instantclient_23_26")

import argparse
import os

dir = os.path.dirname(os.path.realpath(__file__))
query_file = './query.sql'
out_dir = './out'
ts_fmt = '%m%d%Y_%H%M%S'

def connectToDB() -> cx_Oracle.Connection:
    load_dotenv() # load DB env vars in .env
    user = os.environ['ORA_USER']
    pswd = os.environ['ORA_PASS']
    port = os.environ['ORA_PORT']
    host = os.environ['ORA_HOST']
    name = os.environ['ORA_NAME']
    dsn = f'{host}:{port}/{name}'
    return cx_Oracle.connect(user=user, password=pswd, dsn=dsn)

def stripComments(content: str) -> str:
    return '\n'.join([line for line in content.splitlines() if not line.strip().startswith('--')])

# read a query from a .sql file
def readQuery(dir, file) -> str:
    file = os.path.join(dir, file)
    with open(file, 'r') as f:
        content = f.read()

    # remove commented lines, split at semicolons, only return the first statement in the file
    return stripComments(content).split(';')[0].strip()

# execute query with bind vars as dict, must respect named binds
def execQuery(conn: cx_Oracle.Connection, query: str, binds: dict) -> cx_Oracle.Cursor:
    cur = conn.cursor()
    cur.execute(query, binds)
    return cur

# accept a single row from the cursor, make a unique file name
# each row has four values: aidy, rule, sequence, and the SQL statement
def createFileName(row: tuple[str, str, int]) -> str:
    fname = 'rbrabrc_'
    for i, val in enumerate(row):
        fname += f'{val}_'
    return f'{fname[:-1]}.sql'

# iterate through cursor rows, create a directory for each rule, create unique file name for each sequence
def createFiles(rows: list[tuple[str, str, int, cx_Oracle.LOB]], dir: str):
    # create run directory (all .sql files will be written in subdirs within this directory)
    if not os.path.exists(dir):
        os.makedirs(dir)

    # each row contains data for a file to be written: iterate through rows, build file name, 
    # conv LOB SQL statement to string, write to the file
    for row in rows:
        # first three fields contain data for file name
        fname = createFileName(row[:3])

        # file to be saved in directory named after its rule
        file_dir = os.path.join(dir, row[1])

        # create rule directory if it doesn't already exist
        if not os.path.exists(file_dir):
            os.makedirs(file_dir)

        # create full file path
        full_file = Path(os.path.join(file_dir, fname))

        # convert the oracle LOB object to a string
        sql_raw = row[3].read()

        # comment out :PIDM line
        found_pidm = False
        lines = []
        for line in sql_raw.splitlines():
            if ':pidm' in line.lower():
                found_pidm = True
                lines.append('-- ' + line)
                continue
            lines.append(line)
        sql = '\n'.join(lines)

        if not found_pidm:
            print(f'no :pidm bind in {fname}')

        # create and write the sql statement to the file
        with open(full_file, 'w') as f:
            f.write(sql)

        print(f'wrote {os.path.getsize(full_file)} bytes to file at {full_file}')

def main():
    query = readQuery(dir, query_file)
    print(query)

    conn = connectToDB()
    cur = execQuery(conn, query, {"aidy":'2627', "rule": None, "seq": None})

    rows = cur.fetchall()
    print(rows)

    createFiles(rows, os.path.join(dir, out_dir, f'rbrabrc_{datetime.now().strftime(ts_fmt)}'))

if __name__=='__main__':
    main()