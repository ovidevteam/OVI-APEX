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
-- Note: This navigates to Page 1030 to create tasks
-- After tasks created: Current_Step = 'DEV'
-- =====================================================
-- This action redirects to Page 1030 (Tasks)
-- No PL/SQL needed here - handled by navigation

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
-- =====================================================
-- Request: PASS_QA
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DON',                               -- Move to Done
		Status = 'C',                                       -- Status: Completed
		Completed_Date = SYSDATE,                           -- Set completion date
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'QA';                            -- Validate current step

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
BEGIN
	UPDATE WLM_FUNCTIONS
	SET Current_Step = 'DEV',                               -- Return to Development
		Modify_Date = SYSDATE,
		Modified_By = LOWER(v('APP_USER'))
	WHERE Fun_Id = :P1021_FUN_ID
		AND Current_Step = 'QA';                            -- Validate current step

	-- Optionally create a bug task
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
		WLM_TASKS_SEQ.NEXTVAL,
		:P1021_FUN_ID,
		'Bug Fix - QA Failed',
		'QA testing failed. Please review and fix issues.',
		'A',                                                -- Assigned
		:G_EMP_ID,
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

