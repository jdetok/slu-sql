# sfs_utility schema
- created 04/29/2026

## TABLE: pbdg_cutoff_dates
- created 04/29/2026
- provides cutoff dates to reference in period budgeting rules
	- particularly to enable full time defaults for traditional freshmen
- DDL: 
	```sql
	create table sfs_utility.pbdg_cutoff_dates (
		aidy varchar2(4) not null,
		period varchar2(15) not null,
		cutoff date not null,
		constraint pk_pbdg_cutoff_dates primary key (aidy, period)
	);
	```

- ### PROCEDURE: sp_insert_pbdg_cutoff_dates
	- automated fall/spring inserts derived from passed aid year
	- MUST BE LOGGED IN AS sfs_utility TO EXEC
	- `exec sfs_utility.sp_insert_pbdg_cutoff_dates('2627');`
		- inserts rows: 
		```
		AIDY, PERIOD, CUTOFF
		2627	202710	10-JUL-26
		2627	202720	01-DEC-26
		```
	- procedure defaults to July 10 for fall and December 1 for spring
		- can override this by passing specific dates, i.e.:
			- `exec sfs_utility.sp_insert_pbdg_cutoff_dates('2627', '07-05', '12-05');`
			- would result in: 
			```
			AIDY, PERIOD, CUTOFF
			2627	202710	05-JUL-26
			2627	202720	05-DEC-26
			```
	- DDL: 
	```sql
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
	```