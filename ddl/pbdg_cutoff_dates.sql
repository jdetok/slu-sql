-- April 29 2026 Justin DeKock
-- sfs_utility table to store cutoff dates

create table sfs_utility.pbdg_cutoff_dates (
	aidy varchar2(4) not null,
	period varchar2(15) not null,
	fall date,
	spring date,
	constraint pk_pbdg_cutoff_dates primary key (aidy, period)
);

alter table sfs_utility.pbdg_cutoff_dates drop column fall;
alter table sfs_utility.pbdg_cutoff_dates drop column spring;
alter table sfs_utility.pbdg_cutoff_dates add cutoff date not null;

create table sfs_utility.pbdg_cutoff_dates (
	aidy varchar2(4) not null,
	period varchar2(15) not null,
	cutoff date not null,
	constraint pk_pbdg_cutoff_dates primary key (aidy, period)
);
