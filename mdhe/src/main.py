# Parse MO. Dept. of Higher Ed. fixed-width .dat Certification File
# orginaly written by Justin DeKock for SLU SFS Sept. 27, 2025

from readf.layout_xl import open_layout_worksheet, get_layout_rows
from datetime import datetime 
import utl
import logging

# ignore openpyxl warning about unable to parse header/footer
import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="openpyxl")

LOGFILE = f"log/dev_mdhe_{utl.logf_date()}.log"
LAYOUT_FILE = "ref/MDHEWD Spec P16_1 Process - FTP PSI Certification File Layout.xlsx"
LAYOUT_SHEET = "Sheet1"
LAYOUT_START_ROW = 4 # first row of data in the layout file
LAYOUT_START_COL = 0 # first col to parse
LAYOUT_END_COL = 7 # last col to parse
DEV_CRTF = "dat/crt/2025-26_Certification.dat"
DEV_RTNF = f"dat/rtn/2025-26_CertificationReturn_{utl.file_date()}.dat"

# setup logger object
logger = logging.getLogger(__name__)

    
# ENTRYPOINT
def main():
    # configure logging
    logging.basicConfig(level=logging.INFO)
    logger.info(f"{utl.logtime()} script started")
    
    try:
        # open layout file as openpyxl worksheet obejct
        ws = open_layout_worksheet(LAYOUT_FILE, LAYOUT_SHEET)
        
        # iterate over rows in worksheet starting at start row
        # captures fields [start_col:end_col]
        layout_rows = get_layout_rows(ws, LAYOUT_START_ROW, 
                                      LAYOUT_START_COL, LAYOUT_END_COL)
        
        print(layout_rows)
        
        print(utl.fill(11))
        tst = utl.fill_around(11, 'hellotooooolong', justify='right')
        print(f"|{tst}|: length: {len(tst)}")
                  
    except Exception:
        logger.exception(
            f"{utl.logtime()} a fatal error occured. please check log file at {LOGFILE}")
    
# END OF MAIN ==================================================================

if __name__ == "__main__":
    main()