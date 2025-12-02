-- =====================================================
-- Page 1021: Function Form - Form Process (OVI Standard)
-- Purpose: Set values for CREATE/SAVE/DELETE
-- Note: APEX handles DML through built-in form processing
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

BEGIN
	IF :REQUEST = 'CREATE' THEN
		:P1021_FUN_ID := WLM_FUNCTIONS_SEQ.NEXTVAL;
		:P1021_CREATED_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		:P1021_CREATED_BY := LOWER(v('APP_USER'));
		:P1021_CURRENT_STEP := 'BA';
		:P1021_STATUS := 'P';
		-- :P1021_PRIORITY := NVL(:P1021_PRIORITY, 'M');
		:P1021_ACTUAL_HOURS := 0;
	ELSIF :REQUEST = 'SAVE' THEN
		:P1021_MODIFY_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		:P1021_MODIFIED_BY := LOWER(v('APP_USER'));
		:P1021_START_DATE := To_Date(:P1021_START_DATE, v('G_DATE_FORMAT'));
		:P1021_DEADLINE := To_Date(:P1021_DEADLINE, v('G_DATE_FORMAT'));
	ELSIF :REQUEST = 'DELETE' THEN
		Delete From WLM_COMMENTS Where Fun_Id = :P1021_FUN_ID;
		Delete From WLM_TASKS Where Fun_Id = :P1021_FUN_ID;
	END IF;
END;
