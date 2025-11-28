# 📋 WLM - Pages Specification

> **Module:** WLM - Workload Management  
> **Version:** 2.0  
> **Created:** November 2025  
> **Status:** Draft - Giao DEV triển khai

---

## 📑 Danh sách Pages

| Page ID | Page Name | Type | Mô tả |
|---------|-----------|------|-------|
| 1000 | WLM Dashboard | Report/Cards | Tổng quan tiến độ | kiennv
| 1001 | Projects | IG | Danh sách dự án | ducnv
| 1002 | Project Form | Modal Form | Chi tiết dự án | ducnv
| 1010 | Modules | IG | Danh sách modules | kiennv
| 1011 | Module Form | Modal Form | Chi tiết module | kiennv
| 1020 | Functions | IG | Danh sách chức năng | tuannt
| 1021 | Function Form | Modal Form | Chi tiết chức năng | tuannt
| 1030 | Tasks | IG | Danh sách tasks | tuha
| 1031 | Task Form | Modal Form | Chi tiết task | tuha
| 1040 | My Tasks | IG | Tasks được giao cho tôi | tuha
| 1050 | Workflow Board | Cards/Kanban | Bảng workflow theo trạng thái |
| 1060 | User Roles | IG | Phân quyền người dùng | kiennv
| 1070 | Reports | Report | Báo cáo tiến độ | ducnv

---

# 📄 CHI TIẾT TỪNG PAGE

---

## 📊 Page 1000: WLM Dashboard

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1000 |
| **Page Name** | WLM Dashboard |
| **Page Type** | Report / Cards |
| **Page Mode** | Normal |
| **Authorization** | All roles |

### Tables liên quan

| Table | Mục đích | Join/Filter |
|-------|----------|-------------|
| WLM_PROJECTS | Đếm số dự án theo status | GROUP BY Status |
| WLM_FUNCTIONS | Đếm số chức năng theo step/status | GROUP BY Current_Step, Status |
| WLM_TASKS | Đếm tasks, tasks quá hạn | WHERE End_Date < SYSDATE AND Status != 'C' |
| EMPLOYEES | Hiển thị tên nhân viên | JOIN Emp_Id |

### Regions

| Region | Type | Source | Mô tả |
|--------|------|--------|-------|
| Summary Cards | Cards | SQL Query | 4 cards: Tổng dự án, Tổng chức năng, Tasks đang làm, % hoàn thành |
| Projects by Status | Pie Chart | WLM_PROJECTS | GROUP BY Status |
| Functions by Step | Bar Chart | WLM_FUNCTIONS | GROUP BY Current_Step |
| Overdue Tasks | Classic Report | WLM_TASKS + WLM_FUNCTIONS + EMPLOYEES | Tasks quá hạn deadline |
| Recent Activities | Timeline | WLM_COMMENTS | 10 comments gần nhất |

### Process Flow

```
User mở Dashboard
    │
    ▼
Hiển thị tổng quan
    │
    ├── Click vào Card → Navigate to trang tương ứng
    ├── Click vào Chart → Filter theo status/step
    └── Click vào Task → Open Function Form (1021)
```

### Navigation

| Action | Target Page | Parameters |
|--------|-------------|------------|
| Click Card "Dự án" | 1001 | - |
| Click Card "Chức năng" | 1020 | - |
| Click Card "Tasks" | 1040 | - |
| Click Overdue Task row | 1021 | P1021_FUN_ID |

---

## 📋 Page 1001: Projects (IG)

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1001 |
| **Page Name** | Projects |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_PROJECTS_IG |
| **Page Mode** | Normal |
| **Authorization** | ADM: Full, BA: Full, LED/DEV/QA: View |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_PROJECTS** | P | Main table | - |
| EMPLOYEES | E | Hiển thị tên BA | LEFT JOIN E.Emp_Id = P.Ba_Emp_Id |
| APP_VALUE_SET_VL | VS | Hiển thị Status display | JOIN Value = P.Status |
| APP_VALUE_SET_VL_TL | VT | Status theo ngôn ngữ | JOIN VT.Language = :G_LANG |

### IG Query

```sql
SELECT 
    P.Prj_Id,
    P.Project_Code,
    P.Project_Name,
    P.Description,
    P.Ba_Emp_Id,
    E.Full_Name AS Ba_Name,
    P.Start_Date,
    P.Deadline,
    P.Status,
    Pkg_Adm.Get_Lov_Value_Language('WLM_PROJECT_STATUS', P.Status) AS Status_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_PROJECT_STATUS', P.Status) AS Status_Css,
    P.Created_Date,
    P.Created_By
FROM WLM_PROJECTS P
LEFT JOIN EMPLOYEES E ON E.Emp_Id = P.Ba_Emp_Id
WHERE 1=1
```

### Columns

| Column | Display | Type | LOV | Editable | Width |
|--------|---------|------|-----|----------|-------|
| Prj_Id | Hidden | Number | - | N | - |
| Project_Code | Mã dự án | Text | - | Y | 120 |
| Project_Name | Tên dự án | Text | - | Y | 250 |
| Description | Mô tả | Textarea | - | Y | 300 |
| Ba_Emp_Id | Hidden | Number | - | Y | - |
| Ba_Name | BA phụ trách | Display | - | N | 150 |
| Start_Date | Ngày bắt đầu | Date | - | Y | 100 |
| Deadline | Deadline | Date | - | Y | 100 |
| Status | Hidden | Text | - | Y | - |
| Status_Display | Trạng thái | HTML | - | N | 100 |
| Created_Date | Ngày tạo | Date | - | N | 100 |

### LOVs sử dụng

| Field | LOV Name | LOV Query |
|-------|----------|-----------|
| Ba_Emp_Id | LOV_EMPLOYEES | SELECT Full_Name d, Emp_Id r FROM EMPLOYEES WHERE Is_Active = 'Y' |
| Status | WLM_PROJECT_STATUS | A=Active, C=Completed, H=On Hold, X=Cancelled |

### Process Flow

```
User mở Page 1001 (Projects)
    │
    ▼
Hiển thị danh sách dự án (IG)
    │
    ├── [+ Add] → Open Modal 1002 (Create mode)
    │       └── Sau khi save → Refresh IG, Close modal
    │
    ├── [Edit] (row action) → Open Modal 1002 (Edit mode)
    │       └── Sau khi save → Refresh IG, Close modal
    │
    ├── [Delete] (row action) → Confirm → Delete record
    │       └── Refresh IG
    │
    ├── [View Modules] → Navigate to 1010 với P1010_PRJ_ID
    │
    └── IG inline edit → Save all changes
```

### Buttons & Actions

| Button | Type | Action | Process |
|--------|------|--------|---------|
| Add Project | Button | Open Modal 1002 | - |
| Edit | Row Action | Open Modal 1002 | Pass Prj_Id |
| Delete | Row Action | Confirm Dialog | DELETE FROM WLM_PROJECTS |
| View Modules | Row Action | Navigate | Page 1010, P1010_PRJ_ID |
| Save | IG Button | Submit | IG DML |

### IG DML Process

```sql
BEGIN
    CASE :APEX$ROW_STATUS
        WHEN 'C' THEN
            INSERT INTO WLM_PROJECTS (
                Prj_Id, Project_Code, Project_Name, Description,
                Ba_Emp_Id, Start_Date, Deadline, Status,
                Created_Date, Created_By
            ) VALUES (
                WLM_PROJECTS_SEQ.NEXTVAL, :PROJECT_CODE, :PROJECT_NAME, :DESCRIPTION,
                :BA_EMP_ID, :START_DATE, :DEADLINE, NVL(:STATUS, 'A'),
                SYSDATE, LOWER(v('APP_USER'))
            );
        WHEN 'U' THEN
            UPDATE WLM_PROJECTS SET
                Project_Code = :PROJECT_CODE,
                Project_Name = :PROJECT_NAME,
                Description = :DESCRIPTION,
                Ba_Emp_Id = :BA_EMP_ID,
                Start_Date = :START_DATE,
                Deadline = :DEADLINE,
                Status = :STATUS,
                Modify_Date = SYSDATE,
                Modified_By = LOWER(v('APP_USER'))
            WHERE Prj_Id = :PRJ_ID;
        WHEN 'D' THEN
            DELETE FROM WLM_PROJECTS WHERE Prj_Id = :PRJ_ID;
    END CASE;
END;
```

---

## 📝 Page 1002: Project Form

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1002 |
| **Page Name** | Project Form |
| **Page Type** | Modal Dialog Form |
| **Page Mode** | Create / Edit |
| **Dialog Width** | 800px |
| **Authorization** | ADM: Full, BA: Full |

### Tables liên quan

| Table | Alias | Mục đích | Operation |
|-------|-------|----------|-----------|
| **WLM_PROJECTS** | - | Main table | INSERT/UPDATE/DELETE |
| EMPLOYEES | - | LOV cho BA | SELECT |

### Form Query

```sql
SELECT 
    Prj_Id,
    Project_Code,
    Project_Name,
    Description,
    Ba_Emp_Id,
    TO_CHAR(Start_Date, v('G_DATE_FORMAT')) AS Start_Date,
    TO_CHAR(Deadline, v('G_DATE_FORMAT')) AS Deadline,
    Status,
    TO_CHAR(Created_Date, v('G_DATE_FORMAT')) AS Created_Date,
    Created_By,
    TO_CHAR(Modify_Date, v('G_DATE_FORMAT')) AS Modify_Date,
    Modified_By
FROM WLM_PROJECTS
WHERE Prj_Id = :P1002_PRJ_ID
```

### Page Items

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1002_PRJ_ID | - | Hidden | - | - | - |
| P1002_PROJECT_CODE | Mã dự án | Text | - | Y | required-field |
| P1002_PROJECT_NAME | Tên dự án | Text | - | Y | required-field |
| P1002_DESCRIPTION | Mô tả | Textarea | - | N | - |
| P1002_BA_EMP_ID | BA phụ trách | Popup LOV | LOV_EMPLOYEES | N | - |
| P1002_START_DATE | Ngày bắt đầu | Date Picker | - | N | - |
| P1002_DEADLINE | Deadline | Date Picker | - | N | - |
| P1002_STATUS | Trạng thái | Select List | WLM_PROJECT_STATUS | Y | - |
| P1002_CREATED_DATE | Ngày tạo | Display Only | - | - | disable |
| P1002_CREATED_BY | Người tạo | Display Only | - | - | disable |

### LOVs sử dụng

| Field | LOV Name | LOV Query |
|-------|----------|-----------|
| P1002_BA_EMP_ID | LOV_EMPLOYEES | SELECT Full_Name d, Emp_Id r FROM EMPLOYEES WHERE Is_Active = 'Y' ORDER BY Full_Name |
| P1002_STATUS | WLM_PROJECT_STATUS | Pkg_Adm LOV query với :G_LANG |

### Process Flow

```
Modal mở (từ Page 1001)
    │
    ├── Mode = CREATE (P1002_PRJ_ID is null)
    │       │
    │       ▼
    │   Set default values:
    │   - P1002_STATUS = 'A'
    │   - P1002_CREATED_DATE = SYSDATE
    │   - P1002_CREATED_BY = :APP_USER
    │       │
    │       ▼
    │   User nhập thông tin
    │       │
    │       ▼
    │   [CREATE] → INSERT INTO WLM_PROJECTS
    │       │
    │       ▼
    │   Close modal, Refresh parent IG
    │
    └── Mode = EDIT (P1002_PRJ_ID has value)
            │
            ▼
        Fetch data from WLM_PROJECTS
            │
            ▼
        User chỉnh sửa
            │
            ├── [SAVE] → UPDATE WLM_PROJECTS
            │       └── Close modal, Refresh parent IG
            │
            └── [DELETE] → Confirm → DELETE FROM WLM_PROJECTS
                    └── Close modal, Refresh parent IG
```

### Buttons

| Button | Position | Action | Condition |
|--------|----------|--------|-----------|
| CREATE | Create | Submit page, request = CREATE | :P1002_PRJ_ID IS NULL |
| SAVE | Change | Submit page, request = SAVE | :P1002_PRJ_ID IS NOT NULL |
| DELETE | Delete | Confirm, Submit page, request = DELETE | :P1002_PRJ_ID IS NOT NULL |
| CANCEL | Close | Close dialog | Always |

### Form Process

```sql
BEGIN
    IF :REQUEST = 'CREATE' THEN
        INSERT INTO WLM_PROJECTS (
            Prj_Id, Project_Code, Project_Name, Description,
            Ba_Emp_Id, Start_Date, Deadline, Status,
            Created_Date, Created_By
        ) VALUES (
            WLM_PROJECTS_SEQ.NEXTVAL,
            :P1002_PROJECT_CODE,
            :P1002_PROJECT_NAME,
            :P1002_DESCRIPTION,
            :P1002_BA_EMP_ID,
            TO_DATE(:P1002_START_DATE, v('G_DATE_FORMAT')),
            TO_DATE(:P1002_DEADLINE, v('G_DATE_FORMAT')),
            :P1002_STATUS,
            SYSDATE,
            LOWER(v('APP_USER'))
        );
        
    ELSIF :REQUEST = 'SAVE' THEN
        UPDATE WLM_PROJECTS SET
            Project_Code = :P1002_PROJECT_CODE,
            Project_Name = :P1002_PROJECT_NAME,
            Description = :P1002_DESCRIPTION,
            Ba_Emp_Id = :P1002_BA_EMP_ID,
            Start_Date = TO_DATE(:P1002_START_DATE, v('G_DATE_FORMAT')),
            Deadline = TO_DATE(:P1002_DEADLINE, v('G_DATE_FORMAT')),
            Status = :P1002_STATUS,
            Modify_Date = SYSDATE,
            Modified_By = LOWER(v('APP_USER'))
        WHERE Prj_Id = :P1002_PRJ_ID;
        
    ELSIF :REQUEST = 'DELETE' THEN
        DELETE FROM WLM_PROJECTS WHERE Prj_Id = :P1002_PRJ_ID;
    END IF;
END;
```

---

## 📋 Page 1010: Modules (IG)

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1010 |
| **Page Name** | Modules |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_MODULES_IG |
| **Page Mode** | Normal |
| **Master-Detail** | Filter by P1010_PRJ_ID |
| **Authorization** | ADM/BA: Full, LED/DEV/QA: View |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_MODULES** | M | Main table | - |
| WLM_PROJECTS | P | Hiển thị tên dự án | JOIN P.Prj_Id = M.Prj_Id |

### Filter Items

| Item | Label | Type | LOV | Default |
|------|-------|------|-----|---------|
| P1010_PRJ_ID | Dự án | Select List | LOV_WLM_PROJECTS | - |

### IG Query

```sql
SELECT 
    M.Mod_Id,
    M.Prj_Id,
    P.Project_Name,
    M.Module_Code,
    M.Module_Name,
    M.Description,
    M.Sort_Order,
    M.Created_Date,
    M.Created_By
FROM WLM_MODULES M
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
WHERE M.Prj_Id = NVL(:P1010_PRJ_ID, M.Prj_Id)
```

### Columns

| Column | Display | Type | LOV | Editable | Width |
|--------|---------|------|-----|----------|-------|
| Mod_Id | Hidden | Number | - | N | - |
| Prj_Id | Hidden | Number | - | Y | - |
| Project_Name | Dự án | Display | - | N | 200 |
| Module_Code | Mã module | Text | - | Y | 120 |
| Module_Name | Tên module | Text | - | Y | 250 |
| Description | Mô tả | Textarea | - | Y | 300 |
| Sort_Order | Thứ tự | Number | - | Y | 80 |

### LOVs sử dụng

| Field | LOV Name | LOV Query |
|-------|----------|-----------|
| P1010_PRJ_ID | LOV_WLM_PROJECTS | SELECT Project_Name d, Prj_Id r FROM WLM_PROJECTS WHERE Status = 'A' ORDER BY Project_Name |
| Prj_Id (IG) | LOV_WLM_PROJECTS | Same as above |

### Process Flow

```
User mở Page 1010
    │
    ├── Từ Page 1001 (có P1010_PRJ_ID)
    │       └── Hiển thị modules của dự án đó
    │
    └── Trực tiếp (không có filter)
            └── Hiển thị tất cả modules
    │
    ▼
Chọn Dự án filter (P1010_PRJ_ID)
    │
    ▼
IG refresh với filter
    │
    ├── [+ Add] → IG Add row (inline) hoặc Open Modal 1011
    │
    ├── [Edit] → IG inline edit hoặc Open Modal 1011
    │
    ├── [Delete] → Confirm → Delete
    │
    └── [View Functions] → Navigate to 1020 với P1020_MOD_ID
```

### IG DML Process

```sql
BEGIN
    CASE :APEX$ROW_STATUS
        WHEN 'C' THEN
            INSERT INTO WLM_MODULES (
                Mod_Id, Prj_Id, Module_Code, Module_Name,
                Description, Sort_Order, Created_Date, Created_By
            ) VALUES (
                WLM_MODULES_SEQ.NEXTVAL, :PRJ_ID, :MODULE_CODE, :MODULE_NAME,
                :DESCRIPTION, NVL(:SORT_ORDER, 0), SYSDATE, LOWER(v('APP_USER'))
            );
        WHEN 'U' THEN
            UPDATE WLM_MODULES SET
                Prj_Id = :PRJ_ID,
                Module_Code = :MODULE_CODE,
                Module_Name = :MODULE_NAME,
                Description = :DESCRIPTION,
                Sort_Order = :SORT_ORDER,
                Modify_Date = SYSDATE,
                Modified_By = LOWER(v('APP_USER'))
            WHERE Mod_Id = :MOD_ID;
        WHEN 'D' THEN
            DELETE FROM WLM_MODULES WHERE Mod_Id = :MOD_ID;
    END CASE;
END;
```

---

## 📋 Page 1020: Functions (IG)

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1020 |
| **Page Name** | Functions |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_FUNCTIONS_IG |
| **Page Mode** | Normal |
| **Authorization** | ADM/BA: Full, LED: Edit, DEV/QA: View |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_FUNCTIONS** | F | Main table | - |
| WLM_MODULES | M | Tên module | JOIN M.Mod_Id = F.Mod_Id |
| WLM_PROJECTS | P | Tên dự án | JOIN P.Prj_Id = M.Prj_Id |
| EMPLOYEES | E1 | Tên BA | LEFT JOIN E1.Emp_Id = F.Ba_Emp_Id |
| EMPLOYEES | E2 | Tên Leader | LEFT JOIN E2.Emp_Id = F.Lead_Emp_Id |
| EMPLOYEES | E3 | Tên QA | LEFT JOIN E3.Emp_Id = F.Qa_Emp_Id |

### Filter Items

| Item | Label | Type | LOV | Cascade |
|------|-------|------|-----|---------|
| P1020_PRJ_ID | Dự án | Select List | LOV_WLM_PROJECTS | - |
| P1020_MOD_ID | Module | Select List | LOV_WLM_MODULES | Cascade từ P1020_PRJ_ID |
| P1020_STATUS | Trạng thái | Select List | WLM_FUNCTION_STATUS | - |
| P1020_CURRENT_STEP | Bước | Select List | WLM_WORKFLOW_STEP | - |

### IG Query

```sql
SELECT 
    F.Fun_Id,
    F.Mod_Id,
    M.Module_Name,
    P.Project_Name,
    F.Function_Code,
    F.Function_Name,
    F.Description,
    F.Technical_Desc,
    F.Ba_Emp_Id,
    E1.Full_Name AS Ba_Name,
    F.Lead_Emp_Id,
    E2.Full_Name AS Lead_Name,
    F.Qa_Emp_Id,
    E3.Full_Name AS Qa_Name,
    F.Current_Step,
    Pkg_Adm.Get_Lov_Value_Language('WLM_WORKFLOW_STEP', F.Current_Step) AS Step_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_WORKFLOW_STEP', F.Current_Step) AS Step_Css,
    F.Status,
    Pkg_Adm.Get_Lov_Value_Language('WLM_FUNCTION_STATUS', F.Status) AS Status_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_FUNCTION_STATUS', F.Status) AS Status_Css,
    F.Priority,
    Pkg_Adm.Get_Lov_Value_Language('WLM_PRIORITY', F.Priority) AS Priority_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_PRIORITY', F.Priority) AS Priority_Css,
    F.Estimated_Hours,
    F.Actual_Hours,
    F.Start_Date,
    F.Deadline,
    F.Completed_Date,
    F.Created_Date,
    F.Created_By
FROM WLM_FUNCTIONS F
JOIN WLM_MODULES M ON M.Mod_Id = F.Mod_Id
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
LEFT JOIN EMPLOYEES E1 ON E1.Emp_Id = F.Ba_Emp_Id
LEFT JOIN EMPLOYEES E2 ON E2.Emp_Id = F.Lead_Emp_Id
LEFT JOIN EMPLOYEES E3 ON E3.Emp_Id = F.Qa_Emp_Id
WHERE M.Prj_Id = NVL(:P1020_PRJ_ID, M.Prj_Id)
  AND F.Mod_Id = NVL(:P1020_MOD_ID, F.Mod_Id)
  AND F.Status = NVL(:P1020_STATUS, F.Status)
  AND F.Current_Step = NVL(:P1020_CURRENT_STEP, F.Current_Step)
```

### Columns

| Column | Display | Type | LOV | Editable | Width |
|--------|---------|------|-----|----------|-------|
| Fun_Id | Hidden | Number | - | N | - |
| Mod_Id | Hidden | Number | - | Y | - |
| Module_Name | Module | Display | - | N | 150 |
| Project_Name | Dự án | Display | - | N | 150 |
| Function_Code | Mã CN | Text | - | Y | 100 |
| Function_Name | Tên chức năng | Text | - | Y | 200 |
| Ba_Name | BA | Display | - | N | 120 |
| Lead_Name | Leader | Display | - | N | 120 |
| Step_Display | Bước | HTML (badge) | - | N | 100 |
| Status_Display | Trạng thái | HTML (badge) | - | N | 100 |
| Priority_Display | Ưu tiên | HTML (badge) | - | N | 80 |
| Deadline | Deadline | Date | - | N | 100 |

### LOVs sử dụng

| Field | LOV Name | LOV Query |
|-------|----------|-----------|
| P1020_PRJ_ID | LOV_WLM_PROJECTS | SELECT Project_Name d, Prj_Id r FROM WLM_PROJECTS WHERE Status = 'A' |
| P1020_MOD_ID | LOV_WLM_MODULES_CASCADE | SELECT Module_Name d, Mod_Id r FROM WLM_MODULES WHERE Prj_Id = :P1020_PRJ_ID |
| P1020_STATUS | WLM_FUNCTION_STATUS | P/I/C/R |
| P1020_CURRENT_STEP | WLM_WORKFLOW_STEP | BA/LED/DEV/QA/DON |

### Process Flow theo Role

```
┌─────────────────────────────────────────────────────────────────┐
│                    PAGE 1020: FUNCTIONS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  BA Role:                                                       │
│  ─────────                                                      │
│  [+ Add Function] → Open Modal 1021 (Create)                    │
│       │                                                         │
│       ▼                                                         │
│  Nhập: Function_Code, Function_Name, Description,               │
│        Priority, Deadline, Ba_Emp_Id = :G_EMP_ID                │
│       │                                                         │
│       ▼                                                         │
│  Status = 'P', Current_Step = 'BA'                              │
│       │                                                         │
│       ▼                                                         │
│  [Gửi Leader] → Current_Step = 'LED', Status = 'I'              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DEV Leader Role:                                               │
│  ─────────────────                                              │
│  Filter: Current_Step = 'LED'                                   │
│       │                                                         │
│       ▼                                                         │
│  [Edit] → Open Modal 1021                                       │
│       │                                                         │
│       ▼                                                         │
│  Nhập: Technical_Desc, Lead_Emp_Id = :G_EMP_ID                  │
│       │                                                         │
│       ├── [Phân công DEV] → Navigate to 1030 để tạo Tasks       │
│       │       └── Sau khi tạo Tasks → Current_Step = 'DEV'      │
│       │                                                         │
│       └── [Từ chối] → Current_Step = 'BA', Status = 'R'         │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  QA Role:                                                       │
│  ─────────                                                      │
│  Filter: Current_Step = 'QA'                                    │
│       │                                                         │
│       ▼                                                         │
│  [Edit] → Open Modal 1021 → Thêm Comments (kết quả test)        │
│       │                                                         │
│       ├── [Pass] → Current_Step = 'DON', Status = 'C'           │
│       │                                                         │
│       └── [Fail] → Current_Step = 'DEV', tạo bug Task           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Buttons theo Role

| Button | Role | Condition | Action |
|--------|------|-----------|--------|
| Add Function | BA, ADM | Always | Open Modal 1021 (Create) |
| Edit | All | Always | Open Modal 1021 (Edit) |
| Gửi Leader | BA | Current_Step = 'BA' | Update Current_Step = 'LED' |
| Phân công DEV | LED | Current_Step = 'LED' | Navigate to 1030 |
| Từ chối | LED | Current_Step = 'LED' | Update Status = 'R', Step = 'BA' |
| Pass | QA | Current_Step = 'QA' | Update Step = 'DON', Status = 'C' |
| Fail | QA | Current_Step = 'QA' | Update Step = 'DEV', Create bug Task |
| View Tasks | All | Always | Navigate to 1030 with Fun_Id |

---

## 📝 Page 1021: Function Form

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1021 |
| **Page Name** | Function Form |
| **Page Type** | Modal Dialog Form |
| **Page Mode** | Create / Edit |
| **Dialog Width** | 1000px |
| **Tabs** | 4 tabs |
| **Authorization** | ADM/BA: Full, LED: Edit, DEV/QA: View |

### Tables liên quan

| Table | Mục đích | Operation |
|-------|----------|-----------|
| **WLM_FUNCTIONS** | Main table | INSERT/UPDATE/DELETE |
| WLM_MODULES | LOV cho Module | SELECT |
| WLM_PROJECTS | LOV cascade | SELECT |
| EMPLOYEES | LOV cho BA, Leader, QA | SELECT |
| WLM_COMMENTS | Tab Comments | SELECT/INSERT |
| WLM_TASKS | Tab Tasks (sub-region) | SELECT |

### Form Query

```sql
SELECT 
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
    TO_CHAR(Start_Date, v('G_DATE_FORMAT')) AS Start_Date,
    TO_CHAR(Deadline, v('G_DATE_FORMAT')) AS Deadline,
    TO_CHAR(Completed_Date, v('G_DATE_FORMAT')) AS Completed_Date,
    TO_CHAR(Created_Date, v('G_DATE_FORMAT')) AS Created_Date,
    Created_By
FROM WLM_FUNCTIONS
WHERE Fun_Id = :P1021_FUN_ID
```

### Page Items - Tab 1: Thông tin chung

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1021_FUN_ID | - | Hidden | - | - | - |
| P1021_PRJ_ID | Dự án | Select List | LOV_WLM_PROJECTS | Y | required-field |
| P1021_MOD_ID | Module | Select List | LOV_WLM_MODULES_CASCADE | Y | required-field |
| P1021_FUNCTION_CODE | Mã chức năng | Text | - | Y | required-field |
| P1021_FUNCTION_NAME | Tên chức năng | Text | - | Y | required-field |
| P1021_DESCRIPTION | Mô tả BA | Rich Text Editor | - | N | - |
| P1021_TECHNICAL_DESC | Mô tả kỹ thuật | Rich Text Editor | - | N | - |
| P1021_PRIORITY | Độ ưu tiên | Radio Group | WLM_PRIORITY | Y | - |

### Page Items - Tab 2: Phân công

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1021_BA_EMP_ID | BA | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_LEAD_EMP_ID | DEV Leader | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_QA_EMP_ID | QA | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_CURRENT_STEP | Bước hiện tại | Display Only | WLM_WORKFLOW_STEP | - | disable |
| P1021_STATUS | Trạng thái | Display Only | WLM_FUNCTION_STATUS | - | disable |

### Page Items - Tab 3: Tiến độ

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1021_ESTIMATED_HOURS | Giờ dự kiến | Number | - | N | - |
| P1021_ACTUAL_HOURS | Giờ thực tế | Number | - | N | disable |
| P1021_START_DATE | Ngày bắt đầu | Date Picker | - | N | - |
| P1021_DEADLINE | Deadline | Date Picker | - | N | - |
| P1021_COMPLETED_DATE | Ngày hoàn thành | Date Picker | - | N | disable |

### Tab 4: Tasks & Comments (Sub-regions)

| Region | Type | Table | Filter |
|--------|------|-------|--------|
| Tasks | Interactive Grid | WLM_TASKS | Fun_Id = :P1021_FUN_ID |
| Comments | Interactive Grid | WLM_COMMENTS | Fun_Id = :P1021_FUN_ID |

### Workflow Buttons (Dynamic)

| Button | Condition (Current_Step) | Action |
|--------|--------------------------|--------|
| CREATE | :P1021_FUN_ID IS NULL | Insert, Set Status='P', Step='BA' |
| SAVE | Always | Update record |
| Gửi Leader | = 'BA' AND Role = BA | Set Step='LED', Status='I' |
| Phân công DEV | = 'LED' AND Role = LED | Navigate to 1030 |
| Từ chối | = 'LED' AND Role = LED | Set Step='BA', Status='R' |
| Pass | = 'QA' AND Role = QA | Set Step='DON', Status='C', Completed_Date=SYSDATE |
| Fail | = 'QA' AND Role = QA | Set Step='DEV', Create bug Task |
| Đóng | = 'DON' AND Role = BA | Final close |
| Mở lại | = 'DON' AND Role = BA | Set Step='DEV', Status='I' |
| DELETE | :P1021_FUN_ID IS NOT NULL AND Role = ADM | Delete record |

---

## 📋 Page 1030: Tasks (IG)

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1030 |
| **Page Name** | Tasks |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_TASKS_IG |
| **Page Mode** | Normal |
| **Authorization** | ADM/LED: Full, BA/QA: View, DEV: Own tasks |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_TASKS** | T | Main table | - |
| WLM_FUNCTIONS | F | Tên chức năng | JOIN F.Fun_Id = T.Fun_Id |
| WLM_MODULES | M | Tên module | JOIN M.Mod_Id = F.Mod_Id |
| WLM_PROJECTS | P | Tên dự án | JOIN P.Prj_Id = M.Prj_Id |
| EMPLOYEES | E1 | Người thực hiện | LEFT JOIN E1.Emp_Id = T.Assigned_To_Emp_Id |
| EMPLOYEES | E2 | Người giao | LEFT JOIN E2.Emp_Id = T.Assigned_By_Emp_Id |

### Filter Items

| Item | Label | Type | LOV |
|------|-------|------|-----|
| P1030_PRJ_ID | Dự án | Select List | LOV_WLM_PROJECTS |
| P1030_FUN_ID | Chức năng | Select List | LOV_WLM_FUNCTIONS (cascade) |
| P1030_STATUS | Trạng thái | Select List | WLM_TASK_STATUS |
| P1030_ASSIGNED_TO | Người thực hiện | Select List | LOV_EMPLOYEES |

### IG Query

```sql
SELECT 
    T.Tas_Id,
    T.Fun_Id,
    F.Function_Name,
    M.Module_Name,
    P.Project_Name,
    T.Assigned_To_Emp_Id,
    E1.Full_Name AS Assigned_To_Name,
    T.Assigned_By_Emp_Id,
    E2.Full_Name AS Assigned_By_Name,
    T.Task_Name,
    T.Description,
    T.Status,
    Pkg_Adm.Get_Lov_Value_Language('WLM_TASK_STATUS', T.Status) AS Status_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_TASK_STATUS', T.Status) AS Status_Css,
    T.Start_Date,
    T.End_Date,
    CASE WHEN T.End_Date < SYSDATE AND T.Status != 'C' THEN 'Y' ELSE 'N' END AS Is_Overdue,
    T.Notes,
    T.Created_Date
FROM WLM_TASKS T
JOIN WLM_FUNCTIONS F ON F.Fun_Id = T.Fun_Id
JOIN WLM_MODULES M ON M.Mod_Id = F.Mod_Id
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
LEFT JOIN EMPLOYEES E1 ON E1.Emp_Id = T.Assigned_To_Emp_Id
LEFT JOIN EMPLOYEES E2 ON E2.Emp_Id = T.Assigned_By_Emp_Id
WHERE M.Prj_Id = NVL(:P1030_PRJ_ID, M.Prj_Id)
  AND T.Fun_Id = NVL(:P1030_FUN_ID, T.Fun_Id)
  AND T.Status = NVL(:P1030_STATUS, T.Status)
  AND T.Assigned_To_Emp_Id = NVL(:P1030_ASSIGNED_TO, T.Assigned_To_Emp_Id)
```

### Columns

| Column | Display | Type | LOV | Editable | Width |
|--------|---------|------|-----|----------|-------|
| Tas_Id | Hidden | Number | - | N | - |
| Fun_Id | Hidden | Number | - | Y | - |
| Function_Name | Chức năng | Display | - | N | 180 |
| Project_Name | Dự án | Display | - | N | 150 |
| Task_Name | Tên task | Text | - | Y | 200 |
| Assigned_To_Emp_Id | Hidden | Number | - | Y | - |
| Assigned_To_Name | Người thực hiện | Display | - | N | 130 |
| Status_Display | Trạng thái | HTML (badge) | - | N | 100 |
| End_Date | Deadline | Date | - | Y | 100 |
| Is_Overdue | Quá hạn | HTML | - | N | 80 |
| Notes | Ghi chú | Textarea | - | Y | 200 |

### Process Flow

```
DEV Leader mở Page 1030 (từ Page 1020 với Fun_Id)
    │
    ▼
Filter: P1030_FUN_ID = Fun_Id từ page trước
    │
    ▼
[+ Add Task] → Thêm row mới
    │
    ├── Nhập: Task_Name, Description, Assigned_To_Emp_Id, End_Date
    │
    ├── Auto-fill: Assigned_By_Emp_Id = :G_EMP_ID
    │              Status = 'A' (Assigned)
    │              Start_Date = SYSDATE
    │
    └── [Save] → INSERT INTO WLM_TASKS
            │
            ▼
        Sau khi có Tasks → Function.Current_Step có thể = 'DEV'
```

### IG DML Process

```sql
BEGIN
    CASE :APEX$ROW_STATUS
        WHEN 'C' THEN
            INSERT INTO WLM_TASKS (
                Tas_Id, Fun_Id, Assigned_To_Emp_Id, Assigned_By_Emp_Id,
                Task_Name, Description, Status, Start_Date, End_Date,
                Notes, Created_Date, Created_By
            ) VALUES (
                WLM_TASKS_SEQ.NEXTVAL, :FUN_ID, :ASSIGNED_TO_EMP_ID, :G_EMP_ID,
                :TASK_NAME, :DESCRIPTION, 'A', SYSDATE, :END_DATE,
                :NOTES, SYSDATE, LOWER(v('APP_USER'))
            );
        WHEN 'U' THEN
            UPDATE WLM_TASKS SET
                Assigned_To_Emp_Id = :ASSIGNED_TO_EMP_ID,
                Task_Name = :TASK_NAME,
                Description = :DESCRIPTION,
                Status = :STATUS,
                End_Date = :END_DATE,
                Notes = :NOTES,
                Modify_Date = SYSDATE,
                Modified_By = LOWER(v('APP_USER'))
            WHERE Tas_Id = :TAS_ID;
        WHEN 'D' THEN
            DELETE FROM WLM_TASKS WHERE Tas_Id = :TAS_ID;
    END CASE;
END;
```

---

## 📋 Page 1040: My Tasks

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1040 |
| **Page Name** | My Tasks |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_MY_TASKS_IG |
| **Page Mode** | Normal |
| **Filter** | Assigned_To_Emp_Id = :G_EMP_ID |
| **Authorization** | All roles (chỉ xem task của mình) |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_TASKS** | T | Main table | WHERE Assigned_To_Emp_Id = :G_EMP_ID |
| WLM_FUNCTIONS | F | Thông tin chức năng | JOIN F.Fun_Id = T.Fun_Id |
| WLM_MODULES | M | Tên module | JOIN M.Mod_Id = F.Mod_Id |
| WLM_PROJECTS | P | Tên dự án | JOIN P.Prj_Id = M.Prj_Id |

### IG Query

```sql
SELECT 
    T.Tas_Id,
    T.Fun_Id,
    F.Function_Name,
    F.Function_Code,
    M.Module_Name,
    P.Project_Name,
    T.Task_Name,
    T.Description,
    T.Status,
    Pkg_Adm.Get_Lov_Value_Language('WLM_TASK_STATUS', T.Status) AS Status_Display,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_TASK_STATUS', T.Status) AS Status_Css,
    T.Start_Date,
    T.End_Date,
    CASE WHEN T.End_Date < SYSDATE AND T.Status != 'C' THEN 'overdue' ELSE '' END AS Row_Class,
    T.Notes,
    F.Priority,
    Pkg_Adm.Get_Value_Set_Css_Style('WLM_PRIORITY', F.Priority) AS Priority_Css
FROM WLM_TASKS T
JOIN WLM_FUNCTIONS F ON F.Fun_Id = T.Fun_Id
JOIN WLM_MODULES M ON M.Mod_Id = F.Mod_Id
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
WHERE T.Assigned_To_Emp_Id = :G_EMP_ID
  AND T.Status != 'C'  -- Chỉ hiện task chưa hoàn thành
```

### Columns

| Column | Display | Type | Editable | Width |
|--------|---------|------|----------|-------|
| Tas_Id | Hidden | Number | N | - |
| Project_Name | Dự án | Display | N | 150 |
| Module_Name | Module | Display | N | 120 |
| Function_Name | Chức năng | Link | N | 180 |
| Task_Name | Task | Text | N | 200 |
| Status_Display | Trạng thái | HTML (badge) | N | 100 |
| End_Date | Deadline | Date | N | 100 |
| Notes | Ghi chú | Textarea | Y | 250 |

### Quick Action Buttons

| Button | Current Status | New Status | Process |
|--------|----------------|------------|---------|
| Bắt đầu | A (Assigned) | I (In Progress) | UPDATE Status, Start_Date = SYSDATE |
| Hoàn thành | I (In Progress) | C (Completed) | UPDATE Status, End_Date = SYSDATE |
| Blocked | A or I | B (Blocked) | UPDATE Status |

### Process Flow

```
DEV mở Page 1040 (My Tasks)
    │
    ▼
Hiển thị danh sách tasks được giao cho :G_EMP_ID
    │
    ├── Task Status = 'A' (Assigned)
    │       │
    │       ▼
    │   [Bắt đầu] → Status = 'I', Start_Date = SYSDATE
    │
    ├── Task Status = 'I' (In Progress)
    │       │
    │       ├── Cập nhật Notes (ghi chú tiến độ)
    │       │
    │       ├── [Hoàn thành] → Status = 'C'
    │       │       │
    │       │       ▼
    │       │   Kiểm tra: Tất cả Tasks của Function = 'C'?
    │       │       │
    │       │       ├── YES → Function.Current_Step = 'QA' (auto)
    │       │       └── NO → Chờ các task khác
    │       │
    │       └── [Blocked] → Status = 'B'
    │               │
    │               ▼
    │           Thông báo đến Leader
    │
    └── [View Function] → Navigate to 1021 với Fun_Id
```

### Auto Update Function Step (Trigger/Process)

```sql
-- Sau khi UPDATE WLM_TASKS.Status = 'C'
-- Kiểm tra và update Function.Current_Step

DECLARE
    v_pending_tasks NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pending_tasks
    FROM WLM_TASKS
    WHERE Fun_Id = :FUN_ID
      AND Status != 'C';
    
    IF v_pending_tasks = 0 THEN
        UPDATE WLM_FUNCTIONS
        SET Current_Step = 'QA',
            Actual_Hours = (SELECT SUM(/* calculate hours */) FROM WLM_TASKS WHERE Fun_Id = :FUN_ID),
            Modify_Date = SYSDATE,
            Modified_By = LOWER(v('APP_USER'))
        WHERE Fun_Id = :FUN_ID;
    END IF;
END;
```

---

## 📋 Page 1060: User Roles (IG)

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1060 |
| **Page Name** | User Roles |
| **Page Type** | Interactive Grid |
| **Static ID** | WLM_USER_ROLES_IG |
| **Page Mode** | Normal |
| **Authorization** | ADM only |

### Tables liên quan

| Table | Alias | Mục đích | Join |
|-------|-------|----------|------|
| **WLM_USER_ROLES** | R | Main table | - |
| EMPLOYEES | E | Tên nhân viên | JOIN E.Emp_Id = R.Emp_Id |
| WLM_PROJECTS | P | Tên dự án | LEFT JOIN P.Prj_Id = R.Prj_Id |

### IG Query

```sql
SELECT 
    R.Usr_Id,
    R.Emp_Id,
    E.Full_Name AS Employee_Name,
    E.Employee_Code,
    R.Role_Code,
    Pkg_Adm.Get_Lov_Value_Language('WLM_USER_ROLE', R.Role_Code) AS Role_Display,
    R.Prj_Id,
    P.Project_Name,
    R.Is_Active,
    R.Created_Date
FROM WLM_USER_ROLES R
JOIN EMPLOYEES E ON E.Emp_Id = R.Emp_Id
LEFT JOIN WLM_PROJECTS P ON P.Prj_Id = R.Prj_Id
WHERE R.Prj_Id = NVL(:P1060_PRJ_ID, R.Prj_Id)
  AND R.Role_Code = NVL(:P1060_ROLE_CODE, R.Role_Code)
```

### Columns

| Column | Display | Type | LOV | Editable | Width |
|--------|---------|------|-----|----------|-------|
| Usr_Id | Hidden | Number | - | N | - |
| Emp_Id | Hidden | Number | - | Y | - |
| Employee_Name | Nhân viên | Popup LOV | LOV_EMPLOYEES | Y | 180 |
| Employee_Code | Mã NV | Display | - | N | 100 |
| Role_Code | Vai trò | Select List | WLM_USER_ROLE | Y | 120 |
| Prj_Id | Hidden | Number | - | Y | - |
| Project_Name | Dự án | Select List | LOV_WLM_PROJECTS | Y | 180 |
| Is_Active | Hoạt động | Switch | Y/N | Y | 80 |

### LOVs sử dụng

| Field | LOV Name | LOV Query |
|-------|----------|-----------|
| Emp_Id | LOV_EMPLOYEES | SELECT Full_Name \|\| ' (' \|\| Employee_Code \|\| ')' d, Emp_Id r FROM EMPLOYEES WHERE Is_Active = 'Y' |
| Role_Code | WLM_USER_ROLE | ADM/BA/LED/DEV/QA |
| Prj_Id | LOV_WLM_PROJECTS | SELECT Project_Name d, Prj_Id r FROM WLM_PROJECTS WHERE Status = 'A' |

---

## 📊 Page 1070: Reports

### Thông tin chung

| Thuộc tính | Giá trị |
|------------|---------|
| **Page ID** | 1070 |
| **Page Name** | Reports |
| **Page Type** | Report Page |
| **Page Mode** | Normal |
| **Authorization** | ADM: Full, Others: View |

### Tables liên quan (tất cả reports)

| Table | Mục đích |
|-------|----------|
| WLM_PROJECTS | Thống kê dự án |
| WLM_FUNCTIONS | Thống kê chức năng |
| WLM_TASKS | Thống kê tasks |
| EMPLOYEES | Thống kê theo người |

### Region 1: Tiến độ theo dự án

```sql
SELECT 
    P.Project_Name,
    COUNT(F.Fun_Id) AS Total_Functions,
    SUM(CASE WHEN F.Status = 'C' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN F.Status = 'I' THEN 1 ELSE 0 END) AS In_Progress,
    SUM(CASE WHEN F.Status = 'P' THEN 1 ELSE 0 END) AS Pending,
    ROUND(SUM(CASE WHEN F.Status = 'C' THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(F.Fun_Id), 0), 1) AS Progress_Pct
FROM WLM_PROJECTS P
LEFT JOIN WLM_MODULES M ON M.Prj_Id = P.Prj_Id
LEFT JOIN WLM_FUNCTIONS F ON F.Mod_Id = M.Mod_Id
WHERE P.Status = 'A'
GROUP BY P.Project_Name
ORDER BY Progress_Pct DESC
```

### Region 2: Tasks quá hạn

```sql
SELECT 
    T.Task_Name,
    F.Function_Name,
    P.Project_Name,
    E.Full_Name AS Assigned_To,
    T.End_Date AS Deadline,
    TRUNC(SYSDATE - T.End_Date) AS Days_Overdue
FROM WLM_TASKS T
JOIN WLM_FUNCTIONS F ON F.Fun_Id = T.Fun_Id
JOIN WLM_MODULES M ON M.Mod_Id = F.Mod_Id
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
LEFT JOIN EMPLOYEES E ON E.Emp_Id = T.Assigned_To_Emp_Id
WHERE T.Status != 'C'
  AND T.End_Date < SYSDATE
ORDER BY Days_Overdue DESC
```

### Region 3: Thống kê theo người

```sql
SELECT 
    E.Full_Name AS Employee_Name,
    COUNT(T.Tas_Id) AS Assigned_Tasks,
    SUM(CASE WHEN T.Status = 'C' THEN 1 ELSE 0 END) AS Completed_Tasks,
    ROUND(SUM(CASE WHEN T.Status = 'C' THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(T.Tas_Id), 0), 1) AS Completion_Rate
FROM EMPLOYEES E
JOIN WLM_TASKS T ON T.Assigned_To_Emp_Id = E.Emp_Id
GROUP BY E.Full_Name
ORDER BY Completion_Rate DESC
```

---

# 📋 TỔNG HỢP

## LOVs Reference

| LOV Code | Type | Sử dụng tại | Values |
|----------|------|-------------|--------|
| WLM_PROJECT_STATUS | Static | 1001, 1002 | A/C/H/X |
| WLM_FUNCTION_STATUS | Static | 1020, 1021 | P/I/C/R |
| WLM_TASK_STATUS | Static | 1030, 1031, 1040 | A/I/C/B |
| WLM_WORKFLOW_STEP | Static | 1020, 1021, 1050 | BA/LED/DEV/QA/DON |
| WLM_PRIORITY | Static | 1020, 1021 | L/M/H/C |
| WLM_USER_ROLE | Static | 1060 | ADM/BA/LED/DEV/QA |
| LOV_EMPLOYEES | Dynamic | All | FROM EMPLOYEES |
| LOV_WLM_PROJECTS | Dynamic | 1010, 1020, 1030, 1060 | FROM WLM_PROJECTS |
| LOV_WLM_MODULES | Dynamic | 1020, 1021 | FROM WLM_MODULES (cascade) |
| LOV_WLM_FUNCTIONS | Dynamic | 1030, 1031 | FROM WLM_FUNCTIONS |

## Authorization Matrix

| Role | 1000 | 1001 | 1002 | 1010 | 1020 | 1021 | 1030 | 1040 | 1060 | 1070 |
|------|------|------|------|------|------|------|------|------|------|------|
| ADM | ✅ | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ | ✅ Full | ✅ |
| BA | ✅ | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ View | ✅ | ❌ | ✅ |
| LED | ✅ | ✅ View | ❌ | ✅ View | ✅ Edit | ✅ Edit | ✅ Full | ✅ | ❌ | ✅ |
| DEV | ✅ | ✅ View | ❌ | ✅ View | ✅ View | ✅ View | ✅ Own | ✅ | ❌ | ✅ |
| QA | ✅ | ✅ View | ❌ | ✅ View | ✅ Edit | ✅ Edit | ✅ View | ✅ | ❌ | ✅ |

---

## Thứ tự triển khai

| # | Page | Ưu tiên | Ghi chú |
|---|------|---------|---------|
| 1 | 1001 Projects IG | 🔴 High | Base table | ducnv
| 2 | 1002 Project Form | 🔴 High | CRUD Projects | ducnv
| 3 | 1010 Modules IG | 🔴 High | Sau khi có Projects | 
| 4 | 1020 Functions IG | 🔴 High | Core functionality | 
| 5 | 1021 Function Form | 🔴 High | Workflow chính | 
| 6 | 1030 Tasks IG | 🔴 High | Task management | 
| 7 | 1040 My Tasks | 🟡 Medium | DEV daily work |
| 8 | 1060 User Roles | 🟡 Medium | Authorization |
| 9 | 1000 Dashboard | 🟢 Low | Summary view |
| 10 | 1070 Reports | 🟢 Low | Reporting |
| 11 | 1050 Workflow Board | 🟢 Low | Nice to have |

---

*Version: 2.0*  
*Last Updated: November 2025*  
*Author: OVI Development Team*
