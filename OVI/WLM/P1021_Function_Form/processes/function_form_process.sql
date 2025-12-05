-- =====================================================
-- Page 1021: Function Form - Form Process (OVI Standard)
-- Purpose: Set values for CREATE/SAVE/DELETE
-- Note: APEX handles DML through built-in form processing
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

DECLARE
	l_module_code   WLM_MODULES.Module_Code%TYPE;
	l_function_code VARCHAR2(100);
BEGIN
	IF :REQUEST = 'CREATE' THEN
		SELECT Module_Code
		  INTO l_module_code
		  FROM WLM_MODULES
		 WHERE Mod_Id = :P1021_MOD_ID;

		l_function_code := pkg_adm.Gen_Sequence_Number(
			p_Table_Col    => 'WLM_FUNCTIONS.FUNCTION_CODE',
			p_Prefix       => l_module_code,
			p_Reset_Type   => 'YEAR',
			p_Separator    => '.',
			p_Digit_Len    => '3',
			p_Execute_Date => SYSDATE
		);

		:P1021_FUNCTION_CODE := l_function_code;
		:P1021_FUN_ID := WLM_FUNCTIONS_SEQ.NEXTVAL;
		:P1021_CREATED_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		:P1021_CREATED_BY := LOWER(v('APP_USER'));
		:P1021_BA_EMP_ID := :G_EMP_ID;
		:P1021_CURRENT_STEP := 'BA';
		:P1021_STATUS := 'P';
		-- :P1021_PRIORITY := NVL(:P1021_PRIORITY, 'M');
		:P1021_ACTUAL_HOURS := 0;
	ELSIF :REQUEST = 'SAVE' THEN
		:P1021_MODIFY_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		-- :P1021_MODIFIED_BY := LOWER(v('APP_USER'));
		-- :P1021_START_DATE := To_Date(:P1021_START_DATE, v('G_DATE_FORMAT'));
		-- :P1021_DEADLINE := To_Date(:P1021_DEADLINE, v('G_DATE_FORMAT'));
        -- :P1021_COMPLETED_DATE := To_Date(:P1021_COMPLETED_DATE, v('G_DATE_FORMAT'));
	ELSIF :REQUEST = 'DELETE' THEN
		Delete From WLM_COMMENTS Where Fun_Id = :P1021_FUN_ID;
		Delete From WLM_TASKS Where Fun_Id = :P1021_FUN_ID;
	END IF;
END;
