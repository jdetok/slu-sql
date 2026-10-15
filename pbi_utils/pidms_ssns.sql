select spriden_id as bid, spbpers_ssn as ssn
from spbpers
join spriden on spriden_pidm = spbpers_pidm and spriden_change_ind is null
where spbpers_ssn is not null
; 