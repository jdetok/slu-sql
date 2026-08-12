# Layout file specification from MDHE
## layout file
- ref/certfile_layout.xlsx
    - provided by MDHE, provides fixed width layout
## LAYOUT FILE MUST FOLLOW THIS LAYOUT
<b> the layout file must follow this structure for the script to work. 
there can be more colunes past E/5 - they will be ignored. this mataches exactly to the layout file receieved from MDHE in Sept. 2025 </b>
- Column A/1: Field Number (integer)
- Column B/2: Start Position (integer)
- Column C/3: End Position (integer)
- Column D/4: Length (integer)
- Column E/5: Field Name (string)

### if for any reason the layout changes, the cols_to_parse and start_col args can be edited