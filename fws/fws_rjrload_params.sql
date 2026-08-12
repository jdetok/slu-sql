select 
	a.rjrpayl_aidy_code,

	-- RJRLOAD param 2 (Payroll ID) - eg. '2025,BW,12'
	a.rjrpayl_year || ',' || a.rjrpayl_pict_code || ',' || a.rjrpayl_payno as param,

	-- RJRLOAD param 6 (Period)
	case
		-- BW 1 - 11 load to spring (YYYY20)
		when a.rjrpayl_payno <= 11
			then to_char(a.rjrpayl_year) || '20'

		-- BW 12 - 17 load to summer (YYYY00)
		when a.rjrpayl_payno <= 17
			then to_char(a.rjrpayl_year + 1) || '00'

		-- BW 18 - 26 load to fall (YYYY10)
		else to_char(a.rjrpayl_year + 1) || '10'
	end as term

from faismgr.rjrpayl a
inner join (
    select  rjrpayl_aidy_code as aidy, max(rjrpayl_payno) as payno
    from faismgr.rjrpayl
    group by rjrpayl_aidy_code 
) b on b.payno = a.rjrpayl_payno
    and b.aidy = a.rjrpayl_aidy_code
--inner join payroll.ptrcaln b
--	on b.ptrcaln_year = a.rjrpayl_year
--	and b.ptrcaln_payno = a.rjrpayl_payno

-- only the current aidy is populated in RJRPAYL - select max year
where a.rjrpayl_aidy_code = (
    select max(rjrpayl_aidy_code)
    from faismgr.rjrpayl
)
and a.rjrpayl_process_ind is null

-- select only record where check date is >= current date
/*and b.ptrcaln_check_date = (
	select min(ptrcaln_check_date)
	from payroll.ptrcaln
	where trunc(ptrcaln_check_date) >= trunc(sysdate)
)*/

-- only payroll that has not yet been run
