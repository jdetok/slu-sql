# read content from .dat file
import logging
logger = logging.getLogger(__name__)

def open_dat(f_name) -> tuple:
    try:
        rows = []
        with open(f_name, 'r') as f:
            # remove last character (newline) from each line
            for line in f:
                rows.append(str(line[0:(len(line) - 1)]))
            
        logger.info(f"read {len(rows)} fixed-width rows from {f_name}")
        return tuple(rows)
                
    except Exception:
        logger.exception("error opening .dat file")