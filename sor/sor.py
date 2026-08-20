# 08/05/2026 Justin DeKock
# export qualtrics survey results, build robusdf update statements

import warnings
warnings.filterwarnings('ignore')

import oracledb
oracledb.init_oracle_client(lib_dir="/Users/dekockjt/oracle/instantclient_23_26")

from datetime import datetime
from dotenv import load_dotenv
from io import BytesIO
from glob import glob
import pandas as pd
import requests
import zipfile
import json

import sys
import os

AIDY = '2627'
SURVEY_FIELDS = [
    'RecordedDate', 'Finished', 'Name', 'Banner ID', 'Email ', 'Student Type',
    'Enrollment - F/S/R_1', 'Enrollment - F/S/R_2', 'Enrollment - F/S/R_3', 'Enrollment - W_1'
]
FNAME = f"./out/robusdf_sor_updates_{datetime.now().strftime('%m%d%Y_%H%M%S')}.sql"

# the env variables below should exist in .env file at same directory level as script
load_dotenv()
api_key = os.getenv('API_KEY')
surv_id = os.getenv('SURVEY_ID')
dta_ctr = os.getenv('DATA_CENTER')

def export_survey(api_key, surv_id, dta_ctr, dir) -> str:
    requestCheckProgress = 0.0
    progressStatus = "inProgress"
    baseUrl = f'https://{dta_ctr}.qualtrics.com/API/v3/surveys/{surv_id}/export-responses/'
    headers = {
        "content-type": "application/json",
        "x-api-token": api_key,
    }
    print(f'Requesting survey results for SurveyID {surv_id} | ({baseUrl})...')

    # create data export
    downloadRequestPayload = json.dumps({"format": 'csv', "useLabels": True})
    downloadRequestResponse = requests.request(
        "POST", 
        url=baseUrl, 
        data=downloadRequestPayload, 
        headers=headers
    )
    progressId = downloadRequestResponse.json()["result"]["progressId"]

    # check request progress status 
    while progressStatus != "complete" and progressStatus != "failed":
        requestCheckUrl = baseUrl + progressId
        requestCheckResponse = requests.request("GET", requestCheckUrl, headers=headers)
        requestCheckProgress = requestCheckResponse.json()["result"]["percentComplete"]
        progressStatus = requestCheckResponse.json()["result"]["status"]
        print(f'Status: {progressStatus} | {requestCheckProgress}')

    if progressStatus == "failed":
        raise Exception("export failed")

    # download the survey results zip file
    requestDownloadUrl = f"{baseUrl}{requestCheckResponse.json()['result']['fileId']}/file"
    print(f'Requesting zip file download ({requestDownloadUrl})...')
    requestDownload = requests.request("GET", requestDownloadUrl, headers=headers, stream=True)
    
    # unzip the file
    zipResults = zipfile.ZipFile(BytesIO(requestDownload.content))
    zipResults.extractall(dir)

    # by default the saved file inherits the survey name
    surveyName = zipResults.namelist()[0]
    extractedFile = os.path.join(dir, surveyName)
    
    # create the new file name and use it to rename the original
    newFile = os.path.join(dir, f"{(surveyName.replace('.csv', '')).replace(' ', '_')}_{datetime.now().strftime('%m%d%Y_%H%M%S')}.csv")
    os.rename(extractedFile, newFile)

    print(f'Raw export file saved as {newFile}')
    return newFile

# read csv file as data frame, etc
def make_results_df(df, ignore_rows = 2):
    results = df[SURVEY_FIELDS].iloc[ignore_rows:].copy()
    raw_len = len(results)

    # convert utc to central
    results['RecordedDate'] = pd.to_datetime(results['RecordedDate']).dt.tz_localize('utc').dt.tz_convert('US/Central')

    # keep only newest of multiple responses per student
    results = results.sort_values('RecordedDate', ascending=False)
    results = results.drop_duplicates(subset='Banner ID', keep='first')

    print(f'Raw responses: {raw_len} | Cleaned responses: {len(results)}')
    return results

# banner prod connection (.env variables must exist)
def connectToDB() -> oracledb.Connection:
    user = os.getenv('ORA_USER')
    pswd = os.getenv('ORA_PASS')
    port = os.getenv('ORA_PORT')
    host = os.getenv('ORA_HOST')
    name = os.getenv('ORA_NAME')
    dsn = f'{host}:{port}/{name}'
    return oracledb.connect(user=user, password=pswd, dsn=dsn)

# provide list of banner ID strings, return pidm ints mapped to banner IDs 
def get_pidms(conn: oracledb.Connection, bids: list[str]) -> dict[str, int]:
    result = {}
    if not bids:
        return result
    CHUNK = 1000
    with conn.cursor() as cur:
        for i in range(0, len(bids), CHUNK):
            chunk = [str(b) for b in bids[i:i + CHUNK]]
            placeholders = ','.join(f':{j+1}' for j in range(len(chunk)))
            sql = f'''
                select spriden_pidm, spriden_id 
                from spriden where spriden_change_ind is null 
                and spriden_id in ({placeholders})
            '''
            cur.execute(sql, chunk)
            for pidm, bid in cur:
                result[bid] = pidm
    return result

# build a sql statement to update 
def build_robusdf_sql(results: pd.DataFrame) -> list[str]:
    sqls = []
    for _, row in results.iterrows():
        comp_date = row['RecordedDate'].strftime('%m/%d/%Y %H:%M:%S')
        comp_todate = f"to_date('{comp_date}', 'MM/DD/YYYY HH24:MI:SS')"
        sql = f"""
update robusdf set 
    robusdf_value_321 = {comp_todate},
    robusdf_value_322 = '{row["Student Type"]}',
    robusdf_value_323 = {row["Enrollment - F/S/R_1"] if pd.notna(row["Enrollment - F/S/R_1"]) else "null"},
    robusdf_value_324 = {row["Enrollment - W_1"] if pd.notna(row["Enrollment - W_1"]) else "null"},
    robusdf_value_325 = {row["Enrollment - F/S/R_2"] if pd.notna(row["Enrollment - F/S/R_2"]) else "null"},
    robusdf_value_326 = {row["Enrollment - F/S/R_3"] if pd.notna(row["Enrollment - F/S/R_3"]) else "null"}
where robusdf_pidm = {row['pidm']} 
and robusdf_aidy_code = '{AIDY}' 
and (robusdf_value_321 is null or to_date(robusdf_value_321, 'DD-MON-RR') < {comp_todate});
""".strip()
        sqls.append(sql)
    return sqls

# output each update statement to a file
def output_sqls(sqls: list[str], fname=FNAME):
    with open(fname, 'w') as f:
        f.write('\n'.join(sqls) + '\n')

# pass any pos arg to skip requesting
def main():
    # if passed with an argument, skip api call and read most recent raw fetch
    if len(sys.argv) > 1:
        file = max(glob('./raw/*.csv'), key=os.path.getmtime)
    else:
        file = export_survey(api_key, surv_id, dta_ctr, './raw')

    # read exported csv file as pandas dataframe
    print(f'Creating results dataframe from {file}')
    df = pd.read_csv(file)

    # make pandas df for results, set of banner ids
    results = make_results_df(df)
    bids = set(results['Banner ID'])

    print(f'Attempting to fetch spriden_pidm from {len(bids)} banner IDs')
    with connectToDB() as conn:
        pidm_map = get_pidms(conn, list(bids))

    # add the fetched pidms as a df column
    results['pidm'] = results['Banner ID'].map(pidm_map).astype('Int64')

    # capture ids without matching pidm
    bad_ids = results[results['pidm'].isna()]['Banner ID'].unique()

    # only keep rows with a pidm
    results = results.dropna(subset=['pidm'])

    print(
        f'spriden_pidm successfully fetched for {len(results)} banner ID(s)',
        f'| {len(bad_ids)} banner ID(s) without a matching pidm: {bad_ids}' if len(bad_ids) else None
    )

    # build robusdf update statements from responses
    sqls = build_robusdf_sql(results)

    # output update statements to .sql file
    print(f'Writing {len(sqls)} update statements to {FNAME}')
    output_sqls(sqls)

    print('complete')
    
if __name__=='__main__':
    main()