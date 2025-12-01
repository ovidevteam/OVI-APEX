-- =====================================================
-- Page 1021: Function Form - Form Query
-- Purpose: Query to load function details for modal form
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

SELECT
	-- =====================================================
	-- Tab 1: General Information
	-- =====================================================
	Fun_Id,                                                 -- NUMBER, PK, Hidden
	Mod_Id,                                                 -- NUMBER, LOV: LOV_WLM_MODULES_CASCADE (CSS: required-field)
	Function_Code,                                          -- VARCHAR2(50), Text (CSS: required-field)
	Function_Name,                                          -- VARCHAR2(200), Text (CSS: required-field)
	Description,                                            -- VARCHAR2(4000), Rich Text Editor
	Technical_Desc,                                         -- VARCHAR2(4000), Rich Text Editor
	Priority,                                               -- VARCHAR2(1), LOV: WLM_PRIORITY (L/M/H/C) (Default: 'M')
	-- =====================================================
	-- Tab 2: Assignment
	-- =====================================================
	Ba_Emp_Id,                                              -- NUMBER, LOV: LOV_EMPLOYEES (Popup LOV)
	Lead_Emp_Id,                                            -- NUMBER, LOV: LOV_EMPLOYEES (Popup LOV)
	Qa_Emp_Id,                                              -- NUMBER, LOV: LOV_EMPLOYEES (Popup LOV)
	Current_Step,                                           -- VARCHAR2(3), LOV: WLM_WORKFLOW_STEP (CSS: disable, Custom: tabindex="-1")
	Pkg_Adm.Get_Lov_Value_Language('WLM_WORKFLOW_STEP', Current_Step) AS Current_Step_Display,    -- Step_Display
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_WORKFLOW_STEP', Current_Step) AS Current_Step_Css,       -- Step_Css
	Status,                                                 -- VARCHAR2(1), LOV: WLM_FUNCTION_STATUS (CSS: disable, Custom: tabindex="-1")
	Pkg_Adm.Get_Lov_Value_Language('WLM_FUNCTION_STATUS', Status) AS Status_Display,              -- Status_Display
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_FUNCTION_STATUS', Status) AS Status_Css,                 -- Status_Css
	-- =====================================================
	-- Tab 3: Progress
	-- =====================================================
	Estimated_Hours,                                        -- NUMBER, Number Field (Format: 999,999.99)
	Actual_Hours,                                           -- NUMBER, Number Field (CSS: disable, Custom: tabindex="-1")
	TO_CHAR(Start_Date, v('G_DATE_FORMAT')) AS Start_Date,  -- DATE, Date Picker (Format: &G_DATE_FORMAT)
	TO_CHAR(Deadline, v('G_DATE_FORMAT')) AS Deadline,      -- DATE, Date Picker (Format: &G_DATE_FORMAT)
	TO_CHAR(Completed_Date, v('G_DATE_FORMAT')) AS Completed_Date,  -- DATE, Date Picker (CSS: disable, Custom: tabindex="-1")
	-- =====================================================
	-- Tab 4: Audit (Read-only)
	-- =====================================================
	TO_CHAR(Created_Date, v('G_DATE_FORMAT')) AS Created_Date,      -- DATE (CSS: disable, Custom: tabindex="-1")
	Created_By,                                             -- VARCHAR2(50) (CSS: disable, Custom: tabindex="-1")
	TO_CHAR(Modify_Date, v('G_DATE_FORMAT')) AS Modify_Date,        -- DATE (CSS: disable, Custom: tabindex="-1")
	Modified_By                                             -- VARCHAR2(50) (CSS: disable, Custom: tabindex="-1")
FROM WLM_FUNCTIONS
WHERE Fun_Id = :P1021_FUN_ID

