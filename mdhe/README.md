# MDHE fixed-width processing
- ## Parse MO. Dept. of Higher Ed. fixed-width .dat Certification File
- ### orginaly written by Justin DeKock for SLU SFS October 2025

# Project intent
This python project reads both a layout excel file and fixed width .dat file from MDHE. The layout file is used to parse and update ~350 fixed width fields in the .dat file, then write the updates to a new .dat file to return to MDHE. This should be executed after an automated process has retrieved the current MDHE Certification file from the MDHE SFTP site. After the code runs, the output .dat file should be uploaded to the SFTP site. 

# High-level process overview
- ### open layout file, create FWLayout object with fixed width fields metadata
- ### open certification .dat file from MDHE, create FWFile object
- ### query banner database for current student data
- ### iterate through fixed width fields (using FWLayout object), update fields with banner data if applicable
- ### create new fixed width line by iterating through fields & concatting each to a single string
- ### create new FWFile object with updated lines
- ### write updated file as CertificationReturn.dat
 
# Packages
- all required packages are listed in requirements.txt and can be installed with
the following command 
    - `pip install -r requirements.txt`

# Python version
- as of 11am 10/15/2025 this project is being developed in `python version 3.12.8`