-- April 29 2026 Justin DeKock
-- stored procedure to insert period budgeting cutoff dates for an aid year
-- by default will insert 07-10-year for fall, 12-01-year for spring
-- call with defaults for 2627:
	-- exec sfs_utility.sp_insert_pbdg_cutoff_dates('2627');
-- call with default dates overridden for 2728:
	-- exec sfs_utility.sp_insert_pbdg_cutoff_dates('2728', '07-05', '12-02');	

create or replace procedure sfs_utility.sp_insert_pbdg_cutoff_dates(
    p_aidy in varchar2,
    p_fall_date in varchar2 default '07-10',
    p_spring_date in varchar2 default '12-01'
) as
    v_year_prefix varchar2(2) := substr(p_aidy, 1, 2);
    v_year_suffix varchar2(2) := substr(p_aidy, 3, 2);
    v_fall_year varchar2(4) := '20' || v_year_prefix;
    v_spring_year varchar2(4) := '20' || v_year_prefix;
    v_fall_period varchar2(6) := '20' || v_year_suffix || '10';
    v_spring_period varchar2(6) := '20' || v_year_suffix || '20';
begin
    insert into sfs_utility.pbdg_cutoff_dates (aidy, period, cutoff)
    values (p_aidy, v_fall_period, to_date(p_fall_date || '-' || v_fall_year, 'MM-DD-YYYY'));

    insert into sfs_utility.pbdg_cutoff_dates (aidy, period, cutoff)
    values (p_aidy, v_spring_period, to_date(p_spring_date || '-' || v_spring_year, 'MM-DD-YYYY'));

    commit;
end;