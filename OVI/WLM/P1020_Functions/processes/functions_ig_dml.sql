-- =====================================================
-- Page 1020: Functions - IG DML (OVI Standard)
-- Purpose: CREATE/UPDATE/DELETE WLM_FUNCTIONS from Interactive Grid
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

BEGIN
	CASE :APEX$ROW_STATUS
		-- =====================================================
		-- CREATE: Insert new function
		-- =====================================================
		WHEN 'C' THEN
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
				WLM_FUNCTIONS_SEQ.NEXTVAL,
				:MOD_ID,
				:FUNCTION_CODE,
				:FUNCTION_NAME,
				:DESCRIPTION,
				:TECHNICAL_DESC,
				:BA_EMP_ID,
				:LEAD_EMP_ID,
				:QA_EMP_ID,
				NVL(:CURRENT_STEP, 'BA'),                   -- Default: BA Review
				NVL(:STATUS, 'P'),                          -- Default: Pending
				NVL(:PRIORITY, 'M'),                        -- Default: Medium
				:ESTIMATED_HOURS,
				:ACTUAL_HOURS,
				:START_DATE,
				:DEADLINE,
				:COMPLETED_DATE,
				SYSDATE,
				LOWER(v('APP_USER'))
			);

		-- =====================================================
		-- UPDATE: Update existing function
		-- =====================================================
		WHEN 'U' THEN
			UPDATE WLM_FUNCTIONS
			SET Mod_Id = :MOD_ID,
				Function_Code = :FUNCTION_CODE,
				Function_Name = :FUNCTION_NAME,
				Description = :DESCRIPTION,
				Technical_Desc = :TECHNICAL_DESC,
				Ba_Emp_Id = :BA_EMP_ID,
				Lead_Emp_Id = :LEAD_EMP_ID,
				Qa_Emp_Id = :QA_EMP_ID,
				Current_Step = :CURRENT_STEP,
				Status = :STATUS,
				Priority = :PRIORITY,
				Estimated_Hours = :ESTIMATED_HOURS,
				Actual_Hours = :ACTUAL_HOURS,
				Start_Date = :START_DATE,
				Deadline = :DEADLINE,
				Completed_Date = :COMPLETED_DATE,
				Modify_Date = SYSDATE,
				Modified_By = LOWER(v('APP_USER'))
			WHERE Fun_Id = :FUN_ID;

		-- =====================================================
		-- DELETE: Delete function by primary key
		-- =====================================================
		WHEN 'D' THEN
			DELETE FROM WLM_FUNCTIONS
			WHERE Fun_Id = :FUN_ID;
	END CASE;
END;
-- NOTE: Use IG built-in processing with this anonymous PL/SQL per-row DML
-- Commit behavior controlled by APEX IG process settings

