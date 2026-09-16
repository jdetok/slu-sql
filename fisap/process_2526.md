# FISAP FWS (Section V) Process 09/16/2026
## Data sources
- ### Paid in banner query
    ```sql
    select 
        rprawrd_pidm as pidm,
        spriden_id as bid,
        rprawrd_aidy_code as aidy,
        rprawrd_paid_amt as paid
    from rprawrd
    join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
    where rprawrd_fund_code = 'FWS'
    and rprawrd_paid_amt is not null
    and rprawrd_aidy_code = '" & aidy & "'
    ```
- ### Excel reports
    - #### YTD Prism Report
        - Tdrive backup:<br>`//ds.slu.edu/DEP/Enrollment Retention Management/Alteryx Reports/Student Financial Services/FISAP/fws_2526/data/prism_fy26.xlsx`
    - #### Community Service Data
        - Tdrive backup:<br>`//ds.slu.edu/DEP/Enrollment Retention Management/Alteryx Reports/Student Financial Services/FISAP/fws_2526/data/commserv_fy26.xlsx`
    
- ## Steps in Power BI
    1. ### Combine the prism and commserv reports to one excel workbook with two sheets (named prism and cs, respectively) and save the Excel file to onedrive
        - This is necessary in order to publish the final in PowerBI (can't publish using a local copy)
    2. ### Using 'Get Data', connect to the excel sheet via onedrive
        1. Find the onedrive path for the Excel file 
            - Login to onedrive on the web and navigate to 'My Files'
            - Click the three dots next to the excel file and click 'Details'
            - In the details pane, click the Copy button next to 'Path' - the path is now in your clipboard.
        2. Paste the path in the connect popup in PBI. Authorize with OAuth2
        3. Do this to import in the different sheets
    3. ### Setup the query above as a data source
    4. ### Create new source from merging paid in banner to prism
    5. ### From that, make another new one from merging that output with commserv