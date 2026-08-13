# query RORCMPL for packaging sql rules, run each rule's query, compare the results to the results of students with said packaging group
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
import os
import csv
import oracledb
oracledb.init_oracle_client(lib_dir="/Users/dekockjt/oracle/instantclient_23_26")

"""
08/04/2026
need to update script to run the the rules in a specific order and stop 
evaluating once a student has been grouped, similar to in banner. 

for example, if PROFL is run first, and the student groups into PROFL, 
they should not show up on the report later on due to te GR/PRL rule or any other
"""

# rules to run
INC_RULES = ['MED4L', 'MED3L', 'MED2L', 'MED1L', 'LAWL', 'PROFL', 'GR/PRL'] 
OUT_DIR = Path(f"./out/legacy_pkg_var_{datetime.now().strftime('%m%d%Y_%H%M%S')}")
AIDY = '2627'
BINDS = {'aidy': AIDY} # query bind variables

PHOLD_RSTAT = ', '.join(f"'{i}'" for i in INC_RULES)
QUERY_RSTAT = f'select rorstat_pidm, rorstat_pgrp_code from rorstat where rorstat_pgrp_code in ({PHOLD_RSTAT}) and rorstat_aidy_code = :aidy'

QUERY_RORSTAT = 'select rorstat_pidm from rorstat where rorstat_pgrp_code in :pgrp and rorstat_aidy_code = :aidy'
QUERY_SPRIDEN = 'select spriden_pidm, spriden_id from spriden where spriden_change_ind is null and spriden_pidm = :pidm'
QUERY_RORCMPL = '''
select rorgdat_grp_code, rorgdat_aidy_code, rorgdat_type_ind, rorgdat_slct, rorcmpl_sql_statement
from rorgdat join rorcmpl on rorcmpl_slct = rorgdat_slct
where rorgdat_aidy_code = :aidy and rorgdat_type_ind = 'P'
'''

def connectToDB() -> oracledb.Connection:
    load_dotenv() # load DB env vars in .env
    user = os.environ['ORA_USER']
    pswd = os.environ['ORA_PASS']
    port = os.environ['ORA_PORT']
    host = os.environ['ORA_HOST']
    name = os.environ['ORA_NAME']
    dsn = f'{host}:{port}/{name}'
    return oracledb.connect(user=user, password=pswd, dsn=dsn)

def getBIDs(conn: oracledb.Connection, pidms: list[int]) -> dict[int, str]:
    result = {}
    if not pidms:
        return result
    CHUNK = 1000
    with conn.cursor() as cur:
        for i in range(0, len(pidms), CHUNK):
            chunk = pidms[i:i + CHUNK]
            placeholders = ','.join(f':{j}' for j in range(len(chunk)))
            sql = f'''
                select spriden_pidm, spriden_id 
                from spriden where spriden_change_ind is null 
                and spriden_pidm in ({placeholders})
            '''
            cur.execute(sql, chunk)
            for pidm, bid in cur:
                result[pidm] = bid
    return result

def main():
    # map with pidms for current groups in rorstat
    print('querying rorstat for current package group populations...')
    grps_current = {}
    with connectToDB() as conn:
        with conn.cursor() as cur:
            cur.execute(QUERY_RSTAT, BINDS)
            for pidm, grp in cur:
                if grp not in grps_current:
                    grps_current[grp] = set()
                grps_current[grp].add(pidm)

    # query rules from rorcmpl
    print('querying rorcmpl for packaging rules...')
    rules = {}
    with connectToDB() as conn:
        with conn.cursor() as cur:
            cur.execute(QUERY_RORCMPL, BINDS)
            for row in cur:
                sql_raw = row[4].read() # rorcmpl_sql_statement CLOB as string
        
                # comment out line with pidm bind variable
                lines = []
                for line in sql_raw.splitlines():
                    if ':pidm' in line.lower():
                        lines.append('-- ' + line)
                        continue
                    lines.append(line)
                # map sql rule to its group code
                rules[row[0]] = '\n'.join(lines) # grp code: sql statement

    # collect a variance dict for each rule
    grp_vars = {}
    grp_pidms = {}

    # run the sql rules for the included group codes
    for grp, rule_sql in rules.items():
        if grp in INC_RULES:
            print(f'Running {grp} rule...')

            # collect pidms that don't exist in both
            variance = {}
            
            # run the rule from rorcmpl_sql_statement
            rule_rc = 0
            rule_pidms = set()
            with connectToDB() as conn:
                with conn.cursor() as cur:
                    cur.execute(rule_sql, BINDS)
                    for row in cur:
                        rule_rc += 1
                        rule_pidms.add(row[0])

            # get students currently with this package group
            rorstat_rc = len(grps_current[grp])
            rorstat_pidms = grps_current[grp]
            
            # find which students are in the rule result set vs have the package group (vice versa)
            add_pidms = rule_pidms - rorstat_pidms
            remove_pidms = rorstat_pidms - rule_pidms

            # create group variance
            for pidm in add_pidms:
                variance[pidm] = 'add'
            for pidm in remove_pidms:
                variance[pidm] = 'remove'
            grp_vars[grp] = variance

            # map a set of all pidms to the group name
            grp_pidms[grp] = rule_pidms | rorstat_pidms

            print(f'Students with rorstat_pgrp_code = {grp}: {rorstat_rc}\nRows from rule: {rule_rc}')

# get banner IDs from pids
    with connectToDB() as conn:
        bid_map = getBIDs(conn, list(set().union(*grp_pidms.values())))

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, stus in grp_vars.items():
        other_pidms = set().union(*(pidms for grp, pidms in grp_pidms.items() if grp != name))
        safe_name = name.replace('/', '')
        fpath = OUT_DIR / f'{safe_name}.csv'
        with open(fpath, 'w', newline='') as f:
            w = csv.writer(f)
            w.writerow(['bid', 'todo'])
            for pidm, todo in stus.items():
                if pidm in other_pidms:
                    continue
                w.writerow([bid_map.get(pidm), todo])

if __name__=="__main__":
    main()