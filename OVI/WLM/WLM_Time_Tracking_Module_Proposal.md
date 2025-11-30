# 🎯 WLM - Workload Management Module

## Mục tiêu hệ thống

- Quản lý các dự án, module, chức năng (tính năng)
- Theo dõi quy trình phát triển từ **BA → DEV Leader → DEV → QA → BA**
- Báo cáo tiến độ tổng quan

---

## 🧩 Danh sách Page & Tính năng cần làm

### 1. Trang Đăng nhập & Dashboard

- **Dashboard tổng quan:** Thống kê số dự án, số task theo trạng thái, tiến độ theo workflow
- **Phân quyền cơ bản:** Admin, BA, DEV Leader, DEV, QA

---

### 2. Quản lý Dự án

**Page:** Danh sách dự án

**Tính năng:**
- Thêm/sửa/xóa dự án
- Gắn BA phụ trách, ngày bắt đầu, deadline

---

### 3. Quản lý Module & Chức năng

**Page:** Danh sách chức năng theo dự án

**Tính năng:**
- Thêm/sửa/xóa chức năng (kèm mã, tên, mô tả, BA phụ trách, loại chức năng, workflow step)
- Gắn DEV Leader, QA phụ trách
- Trạng thái: `Pending` | `In Progress` | `Completed` | `Rejected`

---

### 4. Quy trình Workflow

> **Luồng:** BA → DEV Leader → DEV → QA → BA

#### Page 1: BA - Mô tả chức năng
- BA nhập mô tả sơ bộ, upload mô tả UI
- Chuyển trạng thái sang **"Đã giao cho DEV Leader"**

#### Page 2: DEV Leader - Đánh giá & Phân công
- Xem danh sách chức năng được BA giao
- Bổ sung mô tả kỹ thuật, phân công cho DEV cụ thể
- Chuyển trạng thái sang **"Đã phân công"**

#### Page 3: DEV - Nhận việc & Thực hiện
- Xem danh sách công việc được giao
- Cập nhật tiến độ: `Đang làm` / `Hoàn thành`
- Ghi chú trong quá trình làm

#### Page 4: QA - Kiểm thử
- Xem danh sách chức năng đã dev xong
- Kiểm thử, ghi nhận kết quả: `Pass` / `Fail`
- Nếu fail: chuyển lại cho DEV

#### Page 5: BA - Xác nhận hoàn thành
- Xem danh sách chức năng đã QA pass
- Kiểm tra lần cuối, xác nhận hoàn thành
- Đóng task

---

### 5. Trao đổi liên tục (Comment theo task)

- Mỗi chức năng có một khu vực comment
- Tất cả thành viên tham gia đều có thể trao đổi

---

### 6. Báo cáo & Thống kê

**Page:** Báo cáo tiến độ

**Nội dung:**
- Số task theo trạng thái
- Tiến độ theo dự án
- Danh sách task trễ deadline

---

## 🗂️ Database Design

> **Schema:** ERP (với GRANT và SYNONYM cho APPS)
> **Prefix:** `WLM_` để phân biệt với các module khác

### Danh sách Tables

| # | Table Name | PK | Sequence | Mô tả |
|---|------------|----|---------| ------|
| 1 | WLM_PROJECTS | Prj_Id | WLM_PROJECTS_SEQ | Quản lý dự án |
| 2 | WLM_MODULES | Mod_Id | WLM_MODULES_SEQ | Modules trong dự án |
| 3 | WLM_FUNCTIONS | Fun_Id | WLM_FUNCTIONS_SEQ | Chức năng/tính năng |
| 4 | WLM_TASKS | Tas_Id | WLM_TASKS_SEQ | Task phân công |
| 5 | WLM_WORKFLOW_STEPS | Wfs_Id | WLM_WORKFLOW_STEPS_SEQ | Các bước workflow |
| 6 | WLM_COMMENTS | Com_Id | WLM_COMMENTS_SEQ | Trao đổi/comment |
| 7 | WLM_USER_ROLES | Usr_Id | WLM_USER_ROLES_SEQ | Phân quyền user trong WLM |

---

### Chi tiết cấu trúc Tables

#### 1. WLM_PROJECTS (Dự án)
| Column | Type | Description |
|--------|------|-------------|
| Prj_Id | NUMBER | PK - Primary Key |
| Project_Code | VARCHAR2(50) | Mã dự án |
| Project_Name | VARCHAR2(200) | Tên dự án |
| Description | VARCHAR2(4000) | Mô tả dự án |
| Ba_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (BA phụ trách) |
| Start_Date | DATE | Ngày bắt đầu |
| Deadline | DATE | Hạn hoàn thành |
| Status | VARCHAR2(1) | LOV: WLM_PROJECT_STATUS (A/C/H/X) |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |
| Modify_Date | DATE | |
| Modified_By | VARCHAR2(50) | |

#### 2. WLM_MODULES (Modules)
| Column | Type | Description |
|--------|------|-------------|
| Mod_Id | NUMBER | PK |
| Prj_Id | NUMBER | FK → WLM_PROJECTS |
| Module_Code | VARCHAR2(50) | Mã module |
| Module_Name | VARCHAR2(200) | Tên module |
| Description | VARCHAR2(4000) | Mô tả |
| Sort_Order | NUMBER | Thứ tự sắp xếp |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |
| Modify_Date | DATE | |
| Modified_By | VARCHAR2(50) | |

#### 3. WLM_FUNCTIONS (Chức năng)
| Column | Type | Description |
|--------|------|-------------|
| Fun_Id | NUMBER | PK |
| Mod_Id | NUMBER | FK → WLM_MODULES |
| Function_Code | VARCHAR2(50) | Mã chức năng |
| Function_Name | VARCHAR2(200) | Tên chức năng |
| Description | VARCHAR2(4000) | Mô tả sơ bộ (BA nhập) |
| Technical_Desc | VARCHAR2(4000) | Mô tả kỹ thuật (DEV Leader) |
| Ba_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (BA) |
| Lead_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (DEV Leader) |
| Qa_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (QA) |
| Current_Step | VARCHAR2(3) | LOV: WLM_WORKFLOW_STEP (BA/LED/DEV/QA/DON) |
| Status | VARCHAR2(1) | LOV: WLM_FUNCTION_STATUS (P/I/C/R) |
| Priority | VARCHAR2(1) | LOV: WLM_PRIORITY (L/M/H/C) |
| Estimated_Hours | NUMBER | Số giờ dự kiến |
| Actual_Hours | NUMBER | Số giờ thực tế |
| Start_Date | DATE | Ngày bắt đầu |
| Deadline | DATE | Hạn hoàn thành |
| Completed_Date | DATE | Ngày hoàn thành thực tế |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |
| Modify_Date | DATE | |
| Modified_By | VARCHAR2(50) | |

#### 4. WLM_TASKS (Task phân công)
| Column | Type | Description |
|--------|------|-------------|
| Tas_Id | NUMBER | PK |
| Fun_Id | NUMBER | FK → WLM_FUNCTIONS |
| Assigned_To_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (DEV được giao) |
| Assigned_By_Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (Người giao) |
| Task_Name | VARCHAR2(200) | Tên task |
| Description | VARCHAR2(4000) | Mô tả công việc |
| Status | VARCHAR2(1) | LOV: WLM_TASK_STATUS (A/I/C/B) |
| Start_Date | DATE | Ngày bắt đầu |
| End_Date | DATE | Ngày kết thúc |
| Notes | VARCHAR2(4000) | Ghi chú của DEV |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |
| Modify_Date | DATE | |
| Modified_By | VARCHAR2(50) | |

#### 5. WLM_WORKFLOW_STEPS (Workflow)
| Column | Type | Description |
|--------|------|-------------|
| Wfs_Id | NUMBER | PK |
| Step_Code | VARCHAR2(3) | Mã bước: BA/LED/DEV/QA/DON |
| Step_Name | VARCHAR2(100) | Tên bước hiển thị |
| Role_Code | VARCHAR2(3) | LOV: WLM_USER_ROLE (ADM/BA/LED/DEV/QA) |
| Sort_Order | NUMBER | Thứ tự |
| Next_Step | VARCHAR2(3) | Bước tiếp theo |
| Prev_Step | VARCHAR2(3) | Bước trước đó |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |

#### 6. WLM_COMMENTS (Trao đổi)
| Column | Type | Description |
|--------|------|-------------|
| Com_Id | NUMBER | PK |
| Fun_Id | NUMBER | FK → WLM_FUNCTIONS |
| Tas_Id | NUMBER | FK → WLM_TASKS (optional) |
| Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id (Người gửi) |
| Comment_Text | VARCHAR2(4000) | Nội dung comment |
| Parent_Com_Id | NUMBER | FK → WLM_COMMENTS (reply) |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |

#### 7. WLM_USER_ROLES (Phân quyền)
| Column | Type | Description |
|--------|------|-------------|
| Usr_Id | NUMBER | PK |
| Emp_Id | NUMBER | FK → EMPLOYEES.Emp_Id |
| Role_Code | VARCHAR2(3) | LOV: WLM_USER_ROLE (ADM/BA/LED/DEV/QA) |
| Prj_Id | NUMBER | FK → WLM_PROJECTS (phân quyền theo dự án) |
| Is_Active | VARCHAR2(1) | Y/N |
| Created_Date | DATE | DEFAULT SYSDATE |
| Created_By | VARCHAR2(50) | |
| Modify_Date | DATE | |
| Modified_By | VARCHAR2(50) | |

---

### LOV Values cần tạo

| LOV Name | Code | Display | Mô tả |
|----------|------|---------|-------|
| **WLM_PROJECT_STATUS** | | | Trạng thái dự án |
| | A | Active | Đang hoạt động |
| | C | Completed | Hoàn thành |
| | H | On Hold | Tạm dừng |
| | X | Cancelled | Hủy bỏ |
| **WLM_FUNCTION_STATUS** | | | Trạng thái chức năng |
| | P | Pending | Chờ xử lý |
| | I | In Progress | Đang thực hiện |
| | C | Completed | Hoàn thành |
| | R | Rejected | Từ chối |
| **WLM_TASK_STATUS** | | | Trạng thái task |
| | A | Assigned | Đã giao |
| | I | In Progress | Đang làm |
| | C | Completed | Hoàn thành |
| | B | Blocked | Bị chặn |
| **WLM_WORKFLOW_STEP** | | | Bước workflow (3 chữ) |
| | BA | BA Review | BA mô tả |
| | LED | Leader Assign | Leader phân công |
| | DEV | Development | DEV thực hiện |
| | QA | QA Testing | QA kiểm thử |
| | DON | Done | Hoàn tất |
| **WLM_PRIORITY** | | | Độ ưu tiên |
| | L | Low | Thấp |
| | M | Medium | Trung bình |
| | H | High | Cao |
| | C | Critical | Khẩn cấp |
| **WLM_USER_ROLE** | | | Vai trò (3 chữ - phức tạp) |
| | ADM | Admin | Quản trị viên |
| | BA | BA | Business Analyst |
| | LED | DEV Leader | Trưởng nhóm DEV |
| | DEV | Developer | Lập trình viên |
| | QA | QA | Kiểm thử viên |

---

### Relationships Diagram

```
WLM_PROJECTS (1) ─────┬───── (N) WLM_MODULES
                      │
                      └───── (N) WLM_USER_ROLES
                      
WLM_MODULES (1) ────────────── (N) WLM_FUNCTIONS

WLM_FUNCTIONS (1) ──┬───────── (N) WLM_TASKS
                    │
                    └───────── (N) WLM_COMMENTS

WLM_TASKS (1) ─────────────── (N) WLM_COMMENTS

EMPLOYEES.Emp_Id ←─── FK ───── WLM_* (all employee references)
```

---

## ✅ Tổng số Page dự kiến: 7-8 pages

| # | Page | Mô tả |
|---|------|-------|
| 1 | Login | Đăng nhập hệ thống |
| 2 | Dashboard | Tổng quan tiến độ |
| 3 | Quản lý dự án | CRUD dự án |
| 4 | Quản lý chức năng | CRUD chức năng |
| 5 | Phân công & Nhận việc | Cho DEV Leader & DEV |
| 6 | Kiểm thử & Xác nhận | Cho QA & BA |
| 7 | Báo cáo tiến độ | Dashboard & Reports |
| 8 | Trao đổi | Có thể tích hợp vào trang chi tiết chức năng |

---

---

*Created: November 2025*  
*Module: WLM - Workload Management*  
*Schema: ERP (GRANT to APPS)*  
*Status: Internal Use Only*
