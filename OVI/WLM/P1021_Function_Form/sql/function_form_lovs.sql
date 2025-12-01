-- =====================================================
-- Page 1021: Function Form - LOVs
-- Purpose: LOV queries for form items on Function Form page
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

-- =====================================================
-- LOV: WLM_PROJECTS
-- Item: P1021_PRJ_ID (Hidden, for cascade)
-- Type: Select List
-- =====================================================
SELECT
	Project_Name AS d,                                      -- Display value
	Prj_Id AS r                                             -- Return value (NUMBER)
FROM WLM_PROJECTS
WHERE Status = 'A'                                          -- Only active projects
ORDER BY Project_Name

-- =====================================================
-- LOV: WLM_MODULES_CASCADE
-- Item: P1021_MOD_ID
-- Type: Select List (Cascading from P1021_PRJ_ID)
-- Cascade Parent: P1021_PRJ_ID
-- CSS: required-field
-- =====================================================
SELECT
	Module_Name AS d,                                       -- Display value
	Mod_Id AS r                                             -- Return value (NUMBER)
FROM WLM_MODULES
WHERE Prj_Id = NVL(:P1021_PRJ_ID, Prj_Id)                   -- Cascade filter (optional)
ORDER BY Sort_Order, Module_Name

-- =====================================================
-- LOV: EMPLOYEES
-- Items: P1021_BA_EMP_ID, P1021_LEAD_EMP_ID, P1021_QA_EMP_ID
-- Type: Popup LOV
-- =====================================================
SELECT
	Name || ' (' || Emp_Number || ')' AS d,                 -- Display value
	Emp_Id AS r                                             -- Return value (NUMBER)
FROM EMPLOYEES
WHERE Is_Active = 'Y'
ORDER BY Name

-- =====================================================
-- LOV: WLM_PRIORITY
-- Item: P1021_PRIORITY
-- Type: Radio Group or Select List
-- Values: L=Low, M=Medium, H=High, C=Critical
-- Default: 'M'
-- =====================================================
SELECT
	Pkg_Adm.Get_Lov_Value_Language('WLM_PRIORITY', Value) AS d,     -- Display (translated)
	Value AS r                                                       -- Return value (VARCHAR2(1))
FROM APP_VALUE_SET_VL
WHERE Value_Set_Name = 'WLM_PRIORITY'
ORDER BY Sort_Order

-- =====================================================
-- LOV: WLM_WORKFLOW_STEP (Display Only)
-- Item: P1021_CURRENT_STEP
-- Type: Display Only (with badge styling)
-- Values: BA=BA Review, LED=Leader Assign, DEV=Development, QA=QA Testing, DON=Done
-- CSS: disable, Custom: tabindex="-1"
-- =====================================================
SELECT
	Pkg_Adm.Get_Lov_Value_Language('WLM_WORKFLOW_STEP', Value) AS d,  -- Display (translated)
	Value AS r                                                         -- Return value (VARCHAR2(3))
FROM APP_VALUE_SET_VL
WHERE Value_Set_Name = 'WLM_WORKFLOW_STEP'
ORDER BY Sort_Order

-- =====================================================
-- LOV: WLM_FUNCTION_STATUS (Display Only)
-- Item: P1021_STATUS
-- Type: Display Only (with badge styling)
-- Values: P=Pending, I=In Progress, C=Completed, R=Rejected
-- CSS: disable, Custom: tabindex="-1"
-- =====================================================
SELECT
	Pkg_Adm.Get_Lov_Value_Language('WLM_FUNCTION_STATUS', Value) AS d,  -- Display (translated)
	Value AS r                                                           -- Return value (VARCHAR2(1))
FROM APP_VALUE_SET_VL
WHERE Value_Set_Name = 'WLM_FUNCTION_STATUS'
ORDER BY Sort_Order

