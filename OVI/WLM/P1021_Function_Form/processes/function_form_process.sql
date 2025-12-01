-- =====================================================
-- Page 1021: Function Form - Form Process (OVI Standard)
-- Purpose: CREATE/SAVE/DELETE for WLM_FUNCTIONS form
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

BEGIN
	-- =====================================================
	-- CREATE: Insert new function
	-- Request: CREATE
	-- Condition: :P1021_FUN_ID IS NULL
	-- =====================================================
	IF :REQUEST = 'CREATE' THEN
		-- Generate new ID
		:P1021_FUN_ID := WLM_FUNCTIONS_SEQ.NEXTVAL;

		-- Set audit fields
		:P1021_CREATED_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		:P1021_CREATED_BY := LOWER(v('APP_USER'));

		-- Set default values
		:P1021_CURRENT_STEP := 'BA';                        -- Default: BA Review
		:P1021_STATUS := 'P';                               -- Default: Pending
		:P1021_PRIORITY := NVL(:P1021_PRIORITY, 'M');       -- Default: Medium
		:P1021_ACTUAL_HOURS := 0;                           -- Default: 0

		INSERT INTO WLM_FUNCTIONS (
			Fun_Id,
			Mod_Id,
			Function_Code,
			Function_Name,
			Description,
			Technical_Desc,
			Ba_Emp_Id,
			Lead_Emp_Id,
			Qa_Emp_Id,
			Current_Step,
			Status,
			Priority,
			Estimated_Hours,
			Actual_Hours,
			Start_Date,
			Deadline,
			Completed_Date,
			Created_Date,
			Created_By
		) VALUES (
			:P1021_FUN_ID,
			:P1021_MOD_ID,
			:P1021_FUNCTION_CODE,
			:P1021_FUNCTION_NAME,
			:P1021_DESCRIPTION,
			:P1021_TECHNICAL_DESC,
			:P1021_BA_EMP_ID,
			:P1021_LEAD_EMP_ID,
			:P1021_QA_EMP_ID,
			:P1021_CURRENT_STEP,
			:P1021_STATUS,
			:P1021_PRIORITY,
			:P1021_ESTIMATED_HOURS,
			:P1021_ACTUAL_HOURS,
			TO_DATE(:P1021_START_DATE, v('G_DATE_FORMAT')),
			TO_DATE(:P1021_DEADLINE, v('G_DATE_FORMAT')),
			TO_DATE(:P1021_COMPLETED_DATE, v('G_DATE_FORMAT')),
			SYSDATE,
			LOWER(v('APP_USER'))
		);

	-- =====================================================
	-- SAVE: Update existing function
	-- Request: SAVE
	-- Condition: :P1021_FUN_ID IS NOT NULL
	-- =====================================================
	ELSIF :REQUEST = 'SAVE' THEN
		-- Set modify audit fields
		:P1021_MODIFY_DATE := TO_CHAR(SYSDATE, v('G_DATE_FORMAT'));
		:P1021_MODIFIED_BY := LOWER(v('APP_USER'));

		UPDATE WLM_FUNCTIONS
		SET Mod_Id = :P1021_MOD_ID,
			Function_Code = :P1021_FUNCTION_CODE,
			Function_Name = :P1021_FUNCTION_NAME,
			Description = :P1021_DESCRIPTION,
			Technical_Desc = :P1021_TECHNICAL_DESC,
			Ba_Emp_Id = :P1021_BA_EMP_ID,
			Lead_Emp_Id = :P1021_LEAD_EMP_ID,
			Qa_Emp_Id = :P1021_QA_EMP_ID,
			Priority = :P1021_PRIORITY,
			Estimated_Hours = :P1021_ESTIMATED_HOURS,
			Start_Date = TO_DATE(:P1021_START_DATE, v('G_DATE_FORMAT')),
			Deadline = TO_DATE(:P1021_DEADLINE, v('G_DATE_FORMAT')),
			Modify_Date = SYSDATE,
			Modified_By = LOWER(v('APP_USER'))
		WHERE Fun_Id = :P1021_FUN_ID;

	-- =====================================================
	-- DELETE: Delete function
	-- Request: DELETE
	-- Condition: :P1021_FUN_ID IS NOT NULL AND Role = ADM
	-- =====================================================
	ELSIF :REQUEST = 'DELETE' THEN
		-- Delete related comments first
		DELETE FROM WLM_COMMENTS WHERE Fun_Id = :P1021_FUN_ID;

		-- Delete related tasks
		DELETE FROM WLM_TASKS WHERE Fun_Id = :P1021_FUN_ID;

		-- Delete function
		DELETE FROM WLM_FUNCTIONS WHERE Fun_Id = :P1021_FUN_ID;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END;
-- NOTE: Commit handled by APEX form processing

