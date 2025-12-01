-- =====================================================
-- Page 1020: Functions - Filter LOVs
-- Purpose: LOV queries for filter items on Functions IG page
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

-- =====================================================
-- LOV: LOV_WLM_PROJECTS
-- Item: P1020_PRJ_ID
-- Type: Select List
-- =====================================================
SELECT
	Project_Name AS d,                                      -- Display value
	Prj_Id AS r                                             -- Return value (NUMBER)
FROM WLM_PROJECTS
WHERE Status = 'A'                                          -- Only active projects
ORDER BY Project_Name

-- =====================================================
-- LOV: LOV_WLM_MODULES_CASCADE
-- Item: P1020_MOD_ID
-- Type: Select List (Cascading from P1020_PRJ_ID)
-- Cascade Parent: P1020_PRJ_ID
-- =====================================================
SELECT
	Module_Name AS d,                                       -- Display value
	Mod_Id AS r                                             -- Return value (NUMBER)
FROM WLM_MODULES
WHERE Prj_Id = :P1020_PRJ_ID                                -- Cascade filter
ORDER BY Sort_Order, Module_Name

-- =====================================================
-- LOV: WLM_FUNCTION_STATUS
-- Item: P1020_STATUS
-- Type: Select List (Static LOV from APP_VALUE_SET)
-- Values: P=Pending, I=In Progress, C=Completed, R=Rejected
-- =====================================================
SELECT
	Pkg_Adm.Get_Lov_Value_Language('WLM_FUNCTION_STATUS', Value) AS d,    -- Display (translated)
	Value AS r                                                              -- Return value (VARCHAR2(1))
FROM APP_VALUE_SET_VL
WHERE Value_Set_Name = 'WLM_FUNCTION_STATUS'
ORDER BY Sort_Order

-- =====================================================
-- LOV: WLM_WORKFLOW_STEP
-- Item: P1020_CURRENT_STEP
-- Type: Select List (Static LOV from APP_VALUE_SET)
-- Values: BA=BA Review, LED=Leader Assign, DEV=Development, QA=QA Testing, DON=Done
-- =====================================================
SELECT
	Pkg_Adm.Get_Lov_Value_Language('WLM_WORKFLOW_STEP', Value) AS d,      -- Display (translated)
	Value AS r                                                              -- Return value (VARCHAR2(3))
FROM APP_VALUE_SET_VL
WHERE Value_Set_Name = 'WLM_WORKFLOW_STEP'
ORDER BY Sort_Order

