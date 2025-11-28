-- Active: 1757905049983@@14.225.71.26@1521@pdbctsdev.localdomain@APPS
/*
File: WLM_LOVS_DDL.sql
Created: 2025-11-28
Author: OVI Development Team
Purpose: Create LOVs for WLM - Workload Management Module (multi-language)
Change History:
2025-11-28 - Initial creation for all WLM LOVs
*/

/* =============================================================
   LOV 1: WLM_PROJECT_STATUS (Return 1-char: A/C/H/X)
   Trạng thái dự án
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_PROJECT_STATUS', 'WLM Project Status', 'Trạng thái dự án', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_PROJECT_STATUS';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'A', 'Active', 1, 'status-success', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'C', 'Completed', 2, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'H', 'On Hold', 3, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'X', 'Cancelled', 4, 'status-danger', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'A' Then 'Active' When 'C' Then 'Completed' When 'H' Then 'On Hold' When 'X' Then 'Cancelled' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'A' Then 'Đang hoạt động' When 'C' Then 'Hoàn thành' When 'H' Then 'Tạm dừng' When 'X' Then 'Hủy bỏ' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   LOV 2: WLM_FUNCTION_STATUS (Return 1-char: P/I/C/R)
   Trạng thái chức năng
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_FUNCTION_STATUS', 'WLM Function Status', 'Trạng thái chức năng', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_FUNCTION_STATUS';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'P', 'Pending', 1, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'I', 'In Progress', 2, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'C', 'Completed', 3, 'status-success', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'R', 'Rejected', 4, 'status-danger', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'P' Then 'Pending' When 'I' Then 'In Progress' When 'C' Then 'Completed' When 'R' Then 'Rejected' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'P' Then 'Chờ xử lý' When 'I' Then 'Đang thực hiện' When 'C' Then 'Hoàn thành' When 'R' Then 'Từ chối' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   LOV 3: WLM_TASK_STATUS (Return 1-char: A/I/C/B)
   Trạng thái task
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_TASK_STATUS', 'WLM Task Status', 'Trạng thái task', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_TASK_STATUS';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'A', 'Assigned', 1, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'I', 'In Progress', 2, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'C', 'Completed', 3, 'status-success', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'B', 'Blocked', 4, 'status-danger', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'A' Then 'Assigned' When 'I' Then 'In Progress' When 'C' Then 'Completed' When 'B' Then 'Blocked' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'A' Then 'Đã giao' When 'I' Then 'Đang làm' When 'C' Then 'Hoàn thành' When 'B' Then 'Bị chặn' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   LOV 4: WLM_WORKFLOW_STEP (Return 3-char: BA/LED/DEV/QA/DON)
   Bước workflow
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_WORKFLOW_STEP', 'WLM Workflow Step', 'Bước workflow', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_WORKFLOW_STEP';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'BA', 'BA Review', 1, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'LED', 'Leader Assign', 2, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'DEV', 'Development', 3, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'QA', 'QA Testing', 4, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'DON', 'Done', 5, 'status-success', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'BA' Then 'BA Review' When 'LED' Then 'Leader Assign' When 'DEV' Then 'Development' When 'QA' Then 'QA Testing' When 'DON' Then 'Done' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'BA' Then 'BA mô tả' When 'LED' Then 'Leader phân công' When 'DEV' Then 'DEV thực hiện' When 'QA' Then 'QA kiểm thử' When 'DON' Then 'Hoàn tất' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   LOV 5: WLM_PRIORITY (Return 1-char: L/M/H/C)
   Độ ưu tiên
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_PRIORITY', 'WLM Priority', 'Độ ưu tiên', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_PRIORITY';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'L', 'Low', 1, 'status-default', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'M', 'Medium', 2, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'H', 'High', 3, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'C', 'Critical', 4, 'status-critical', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'L' Then 'Low' When 'M' Then 'Medium' When 'H' Then 'High' When 'C' Then 'Critical' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'L' Then 'Thấp' When 'M' Then 'Trung bình' When 'H' Then 'Cao' When 'C' Then 'Khẩn cấp' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   LOV 6: WLM_USER_ROLE (Return 3-char: ADM/BA/LED/DEV/QA)
   Vai trò người dùng
   ============================================================= */
Declare
	v_value_set_id Number;
Begin
	Insert Into App_Value_Sets (Value_Set_Id, Value_Set_Code, Value_Set_Name, Descriptions, Return_Type, Value_Set_Type, Require, Creation_Date, Created_By)
	Values (App_Value_Sets_Seq.Nextval, 'WLM_USER_ROLE', 'WLM User Role', 'Vai trò người dùng', 'Varchar2', 'OBJ', 'N', Sysdate, -1);

	Select Value_Set_Id Into v_value_set_id From App_Value_Sets Where Value_Set_Code = 'WLM_USER_ROLE';

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'ADM', 'Admin', 1, 'status-critical', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'BA', 'BA', 2, 'status-info', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'LED', 'DEV Leader', 3, 'status-warning', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'DEV', 'Developer', 4, 'status-success', Sysdate, -1);

	Insert Into App_Value_Set_Vl (Value_Vl_Id, Value_Set_Id, Value, Descriptions, Sort_Order, Css_Style, Creation_Date, Created_By)
	Values (App_Value_Set_Vl_Seq.Nextval, v_value_set_id, 'QA', 'QA', 5, 'status-info', Sysdate, -1);

	For rec In (
		Select Value_Vl_Id, Value From App_Value_Set_Vl Where Value_Set_Id = v_value_set_id
	) Loop
		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'en',
			Case rec.Value When 'ADM' Then 'Admin' When 'BA' Then 'Business Analyst' When 'LED' Then 'DEV Leader' When 'DEV' Then 'Developer' When 'QA' Then 'QA Tester' End,
			Sysdate, -1);

		Insert Into App_Value_Set_Vl_Tl (Value_Vl_Id, Language, Descriptions, Creation_Date, Created_By)
		Values (rec.Value_Vl_Id, 'vi',
			Case rec.Value When 'ADM' Then 'Quản trị viên' When 'BA' Then 'Business Analyst' When 'LED' Then 'Trưởng nhóm DEV' When 'DEV' Then 'Lập trình viên' When 'QA' Then 'Kiểm thử viên' End,
			Sysdate, -1);
	End Loop;

	Commit;
Exception
	When Others Then
		Rollback;
		Raise;
End;
/

/* =============================================================
   Example LOV SQL for APEX (display d, return r)
   ============================================================= */
-- WLM_PROJECT_STATUS
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_PROJECT_STATUS'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

-- WLM_FUNCTION_STATUS
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_FUNCTION_STATUS'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

-- WLM_TASK_STATUS
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_TASK_STATUS'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

-- WLM_WORKFLOW_STEP
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_WORKFLOW_STEP'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

-- WLM_PRIORITY
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_PRIORITY'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

-- WLM_USER_ROLE
-- Select Avt.Descriptions d, Asv.Value r
-- From App_Value_Sets Avs,
--      App_Value_Set_Vl Asv,
--      App_Value_Set_Vl_Tl Avt
-- Where Avs.Value_Set_Code = 'WLM_USER_ROLE'
--   And Avs.Value_Set_Id = Asv.Value_Set_Id
--   And Avt.Language = :G_LANG
--   And Asv.Value_Vl_Id = Avt.Value_Vl_Id
-- Order By Asv.Sort_Order;

