-- =====================================================
-- Page 1021: Function Form - Workflow Actions
-- Purpose: PL/SQL processes for workflow buttons
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

-- =====================================================
-- Action: SEND_TO_LEADER
-- Button: Send to Leader
-- Condition: Current_Step = 'BA' AND Role = BA
-- Transition: BA -> LED, Status = I (In Progress)
-- =====================================================
-- Request: SEND_TO_LEADER
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'LED',                               -- Move to Leader Assign
		Status = 'I',                                       -- Status: In Progress
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'BA';                            -- Validate current step

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function sent to DEV Leader for assignment.';
END;

-- =====================================================
-- Action: ASSIGN_DEV
-- Button: Assign DEV
-- Condition: Current_Step = 'LED' AND Role = LED
-- Purpose: Create DEV task from Function Form
-- Inputs:
--   - :P1021_FUN_ID      : Function Id
--   - :P1021_CHOOSE_DEV  : Employee (DEV) selected to assign
--   - :G_EMP_ID          : Current user (Leader) -> Assigned_By_Emp_Id
-- Behavior:
--   - Insert one task into WLM_TASKS
--   - Move function step to DEV
-- =====================================================
-- Request: ASSIGN_DEV
DECLARE
	l_tas_id NUMBER;
BEGIN
	IF :P1021_CHOOSE_DEV IS NULL THEN
		APEX_ERROR.ADD_ERROR(
			p_message          => 'Please choose a DEV to assign.',
			p_display_location => APEX_ERROR.c_inline_in_notification
		);
		RETURN;
	END IF;

	l_tas_id := WLM_TASKS_SEQ.NEXTVAL;

	INSERT INTO WLM_TASKS (
		Tas_Id,
		Fun_Id,
		Assigned_To_Emp_Id,
		Assigned_By_Emp_Id,
		Task_Name,
		Description,
		Status,
		Start_Date,
		Created_Date,
		Created_By
	) VALUES (
		l_tas_id,
		:P1021_FUN_ID,
		:P1021_CHOOSE_DEV,
		:G_EMP_ID,
		'DEV Task - ' || :P1021_FUNCTION_CODE,
		'Task created from Assign DEV action on Function Form.',
		'A',                                                -- Assigned
		SYSDATE,
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Tas_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		l_tas_id,
		:G_EMP_ID,
		'Assigned DEV task: ' || :P1021_CHOOSE_DEV,
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	UPDATE WLM_FUNCTIONS
	   SET Current_Step = 'DEV',
	       Modify_Date  = SYSDATE,
	       Modified_By  = LOWER(v('APP_USER'))
	 WHERE Fun_Id = :P1021_FUN_ID
	   AND Current_Step = 'LED';

	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'DEV task created and function moved to Development.';
END;

-- =====================================================
-- Action: REJECT
-- Button: Reject
-- Condition: Current_Step = 'LED' AND Role = LED
-- Transition: LED -> BA, Status = R (Rejected)
-- =====================================================
-- Request: REJECT
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'BA',                                -- Return to BA
		Status = 'R',                                       -- Status: Rejected
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'LED';                           -- Validate current step

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function rejected and returned to BA.';
END;

-- =====================================================
-- Action: PASS_QA
-- Button: Pass
-- Condition: Current_Step = 'QA' AND Role = QA
-- Transition: QA -> DON, Status = C (Completed)
-- Note: Function is completed immediately, no BA confirmation needed
-- =====================================================
-- Request: PASS_QA
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DON',                               -- Move to Done (completed)
		Status = 'C',                                       -- Status: Completed
		Qa_Emp_Id = :G_EMP_ID,                             -- Set QA who tested
		Completed_Date = SYSDATE,                           -- Set completion date
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'QA';                            -- Validate current step

	-- Verify update was successful
	IF SQL%ROWCOUNT = 0 THEN
		APEX_ERROR.ADD_ERROR(
			p_message          => 'Failed to update function. Current step may have changed.',
			p_display_location => APEX_ERROR.c_inline_in_notification
		);
		RETURN;
	END IF;

	-- Add comment for audit trail
	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		:G_EMP_ID,
		'QA passed. Function completed and marked as Done.',
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function passed QA testing and marked as completed.';
END;

-- =====================================================
-- Action: FAIL_QA
-- Button: Fail
-- Condition: Current_Step = 'QA' AND Role = QA
-- Transition: QA -> DEV (for bug fixing)
-- =====================================================
-- Request: FAIL_QA
DECLARE
	l_tas_id NUMBER;
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DEV',                               -- Return to Development
		Status = 'I',                                       -- Status: In Progress (back to DEV for bug fix)
		Qa_Emp_Id = :G_EMP_ID,                             -- Set QA who tested
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'QA';                            -- Validate current step

	-- Verify update was successful
	IF SQL%ROWCOUNT = 0 THEN
		APEX_ERROR.ADD_ERROR(
			p_message          => 'Failed to update function. Current step may have changed.',
			p_display_location => APEX_ERROR.c_inline_in_notification
		);
		RETURN;
	END IF;

	-- Create a bug task
	l_tas_id := WLM_TASKS_SEQ.NEXTVAL;

	INSERT INTO WLM_TASKS (
		Tas_Id,
		Fun_Id,
		Task_Name,
		Description,
		Status,
		Assigned_By_Emp_Id,
		Created_Date,
		Created_By
	) VALUES (
		l_tas_id,
		:P1021_FUN_ID,
		'Bug Fix - QA Failed',
		'QA testing failed. Please review and fix issues.',
		'A',                                                -- Assigned
		:G_EMP_ID,
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Add comment for audit trail
	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Tas_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		l_tas_id,
		:G_EMP_ID,
		'QA failed. Function returned to DEV for bug fixing. Bug fix task created.',
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function failed QA testing. Bug fix task created and returned to DEV.';
END;

-- =====================================================
-- Action: CLOSE
-- Button: Close
-- Condition: Current_Step = 'DON' AND Role = BA
-- Note: Final closure by BA
-- =====================================================
-- Request: CLOSE
BEGIN
	-- BA final confirmation - function already completed
	-- Add comment for audit trail
	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		:G_EMP_ID,
		'Function closed by BA.',
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function has been closed.';
END;

-- =====================================================
-- Action: REOPEN
-- Button: Reopen
-- Condition: Current_Step = 'DON' AND Role = BA
-- Transition: DON -> DEV, Status = I (In Progress)
-- =====================================================
-- Request: REOPEN
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DEV',                               -- Move back to Development
		Status = 'I',                                       -- Status: In Progress
		Completed_Date = NULL,                              -- Clear completion date
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'DON';                           -- Validate current step

	-- Add comment for audit trail
	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		:G_EMP_ID,
		'Function reopened for additional work.',
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Function reopened and returned to Development.';
END;

-- =====================================================
-- Action: UPDATE_TO_DEV (After tasks created)
-- Purpose: Update step to DEV after Leader assigns tasks
-- Called from Page 1030 after tasks are saved
-- =====================================================
-- Request: UPDATE_TO_DEV
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DEV',                               -- Move to Development
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'LED';                           -- Validate current step
END;

-- =====================================================
-- Action: SEND_MESSAGE
-- Button: Send Message (in Comments tab)
-- Condition: Function exists (P1021_FUN_ID IS NOT NULL)
-- Purpose: Create comment from user input
-- Inputs:
--   - :P1021_FUN_ID       : Function Id (required)
--   - :P1021_COMMENT_TEXT : Comment text from user (required)
--   - :P1021_TAS_ID       : Task Id (optional, if comment is on specific task)
--   - :G_EMP_ID           : Current user -> Emp_Id
-- Behavior:
--   - Insert comment into WLM_COMMENTS
--   - Link to Function (and Task if provided)
-- =====================================================
-- Request: SEND_MESSAGE
BEGIN
	IF :P1021_COMMENT_TEXT IS NULL OR TRIM(:P1021_COMMENT_TEXT) = '' THEN
		APEX_ERROR.ADD_ERROR(
			p_message          => 'Please enter a comment.',
			p_display_location => APEX_ERROR.c_inline_in_notification
		);
		RETURN;
	END IF;

	IF :P1021_FUN_ID IS NULL THEN
		APEX_ERROR.ADD_ERROR(
			p_message          => 'Function ID is required.',
			p_display_location => APEX_ERROR.c_inline_in_notification
		);
		RETURN;
	END IF;

	INSERT INTO WLM_COMMENTS (
		Com_Id,
		Fun_Id,
		Tas_Id,
		Emp_Id,
		Comment_Text,
		Created_Date,
		Created_By
	) VALUES (
		WLM_COMMENTS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		:P1021_TAS_ID,                                      -- NULL if not provided
		:G_EMP_ID,
		:P1021_COMMENT_TEXT,
		SYSDATE,
		LOWER(v('APP_USER'))
	);

	-- Clear comment text after successful insert
	:P1021_COMMENT_TEXT := NULL;

	-- Set success message
	APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := 'Comment added successfully.';
END;

