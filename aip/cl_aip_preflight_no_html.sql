PROCEDURE preflight_reg_student_hook(p_pidm NUMBER, p_noncourse_errors IN OUT VARCHAR2)
IS
    lv_whats_my_name VARCHAR2(100) := 'cl_cart_local.preflight_reg_student_hook';
    lv_aip_open NUMBER(1) := 0;
    lv_message CONSTANT VARCHAR2(4000) := 'You have an outstanding action item(s) that must be completed before registration. ' 
        || 'Please navigate to Banner Self Service via MySLU to complete all outstanding items.';
BEGIN
    IF p_pidm IS NULL
    THEN
        RETURN;
    END IF;

    SELECT CASE WHEN EXISTS(
        SELECT 1 FROM general.gcraact a
        JOIN general.gcvasts s ON s.gcvasts_surrogate_id = a.gcraact_gcvasts_id
        JOIN general.gcbactm m ON m.gcbactm_surrogate_id = a.gcraact_gcbactm_id
        WHERE a.gcraact_pidm = p_pidm
        AND a.gcraact_gcvasts_id = 1 -- AIP pending status
        AND m.gcbactm_status_code = 'A'
        AND nvl(s.gcvasts_active_ind, 'Y') = 'Y'
        AND trunc(sysdate) between trunc(a.gcraact_display_start_date) and trunc(a.gcraact_display_end_date)
        AND a.gcraact_user_response_date IS NULL
    ) THEN 1 ELSE 0 END INTO lv_aip_open FROM DUAL;

    IF lv_aip_open = 1 THEN
        IF p_noncourse_errors IS NOT NULL THEN
            p_noncourse_errors := p_noncourse_errors || ',';
        END IF;
            p_noncourse_errors := p_noncourse_errors || '"' || lv_message || '"';
    END IF;

END preflight_reg_student_hook;