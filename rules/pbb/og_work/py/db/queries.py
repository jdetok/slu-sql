rbrabrc = {"table": "FAISMGR.RBRABRC", "query": """
select * from rbrabrc where rbrabrc_aidy_code = '2627' 
and regexp_like(substr(rbrabrc_abrc_code, 1, 1), '^[[:digit:]]+$')
"""}

# rules validation
rtvabrc = {"table": "FAISMGR.RTVABRC", "query": """
select * from rtvabrc where regexp_like(substr(rtvabrc_code, 1, 1), '^[[:digit:]]+$') or rtvabrc_code = 'LFEE'
"""}

# components validation
rtvpbcp = {"table": "FAISMGR.RTVPBCP", "query": """
select * from rtvpbcp where regexp_like(substr(rtvpbcp_code, 1, 1), '^[[:digit:]]+$')
"""}

# groups validation
rtvpbgp = {"table": "FAISMGR.RTVPBGP", "query": """
select * from rtvpbgp where rtvpbgp_code not like '%-%' and rtvpbgp_code not in ('AC', 'NAT', 'REVIEW')
"""}

# rbrpdgr in banner - assign pell rules/components
rbrpell = {"table": "FAISMGR.RBRPELL", "query": """
select * from rbrpell where rbrpell_aidy_code = '2627'
"""}

# assign non-pell rules/components
rbrpbdr = {"table": "FAISMGR.RBRPBDR", "query": """
select * from rbrpbdr where rbrpbdr_aidy_code = '2627'
"""}


rbrpbcp = {"table": "FAISMGR.RBRPBCP", "query": """
select * from rbrpbcp where rbrpbcp_aidy_code = '2627' and rbrpbcp_user_id = 'FA_JOBS'
"""}

rbrpbgp = {"table": "FAISMGR.RBRPBGP", "query": """
select * from rbrpbgp where rbrpbgp_aidy_code = '2627' and rbrpbgp_user_id = 'FA_JOBS'
"""}

roralgs = {"table": "FAISMGR.RORALGS", "query": """
select * from roralgs where roralgs_aidy_code = '2627'
"""}

rbrpgpt = {"table": "FAISMGR.RBRPGPT", "query": """
select * from rbrpgpt where rbrpgpt_aidy_code = '2627'
"""}
