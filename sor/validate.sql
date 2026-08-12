select 
    spriden_id,
    robusdf_pidm,
    robusdf_value_321,
    robusdf_value_322,
    robusdf_value_323,
    robusdf_value_324,
    robusdf_value_325,
    robusdf_value_326
from robusdf
join spriden on spriden_pidm = robusdf_pidm and spriden_change_ind is null
where robusdf_aidy_code = '2627'
and robusdf_value_321 is not null;

select * from robusdf where robusdf_pidm = 1289005;