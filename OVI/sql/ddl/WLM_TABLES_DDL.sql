-- =====================================================
-- WLM - Workload Management Module
-- DDL Script: Tables, Sequences, Grants, Synonyms
-- Schema: ERP (with GRANT to APPS)
-- Created: November 2025
-- Author: OVI Development Team
-- =====================================================

-- =====================================================
-- PHẦN 1: TẠO TABLES VÀ SEQUENCES TRÊN SCHEMA ERP
-- =====================================================

-- Kết nối vào schema ERP
-- ALTER SESSION SET CURRENT_SCHEMA = ERP;

-- -----------------------------------------------------
-- 1. WLM_PROJECTS - Quản lý dự án
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_PROJECTS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_PROJECTS (
    Prj_Id              NUMBER              NOT NULL,
    Project_Code        VARCHAR2(50)        NOT NULL,
    Project_Name        VARCHAR2(200)       NOT NULL,
    Description         VARCHAR2(4000),
    Ba_Emp_Id           NUMBER,
    Start_Date          DATE,
    Deadline            DATE,
    Status              VARCHAR2(1)         DEFAULT 'A',
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    Modify_Date         DATE,
    Modified_By         VARCHAR2(50),
    CONSTRAINT WLM_PROJECTS_PK PRIMARY KEY (Prj_Id),
    CONSTRAINT WLM_PROJECTS_UK UNIQUE (Project_Code)
);

COMMENT ON TABLE ERP.WLM_PROJECTS IS 'WLM - Quản lý dự án';
COMMENT ON COLUMN ERP.WLM_PROJECTS.Status IS 'LOV: WLM_PROJECT_STATUS (A=Active, C=Completed, H=On Hold, X=Cancelled)';

-- -----------------------------------------------------
-- 2. WLM_MODULES - Modules trong dự án
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_MODULES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_MODULES (
    Mod_Id              NUMBER              NOT NULL,
    Prj_Id              NUMBER              NOT NULL,
    Module_Code         VARCHAR2(50)        NOT NULL,
    Module_Name         VARCHAR2(200)       NOT NULL,
    Description         VARCHAR2(4000),
    Sort_Order          NUMBER              DEFAULT 0,
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    Modify_Date         DATE,
    Modified_By         VARCHAR2(50),
    CONSTRAINT WLM_MODULES_PK PRIMARY KEY (Mod_Id),
    CONSTRAINT WLM_MODULES_FK_PRJ FOREIGN KEY (Prj_Id) REFERENCES ERP.WLM_PROJECTS(Prj_Id)
);

COMMENT ON TABLE ERP.WLM_MODULES IS 'WLM - Modules trong dự án';

-- -----------------------------------------------------
-- 3. WLM_FUNCTIONS - Chức năng/tính năng
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_FUNCTIONS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_FUNCTIONS (
    Fun_Id              NUMBER              NOT NULL,
    Mod_Id              NUMBER              NOT NULL,
    Function_Code       VARCHAR2(50)        NOT NULL,
    Function_Name       VARCHAR2(200)       NOT NULL,
    Description         VARCHAR2(4000),
    Technical_Desc      VARCHAR2(4000),
    Ba_Emp_Id           NUMBER,
    Lead_Emp_Id         NUMBER,
    Qa_Emp_Id           NUMBER,
    Current_Step        VARCHAR2(3)         DEFAULT 'BA',
    Status              VARCHAR2(1)         DEFAULT 'P',
    Priority            VARCHAR2(1)         DEFAULT 'M',
    Estimated_Hours     NUMBER,
    Actual_Hours        NUMBER,
    Start_Date          DATE,
    Deadline            DATE,
    Completed_Date      DATE,
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    Modify_Date         DATE,
    Modified_By         VARCHAR2(50),
    CONSTRAINT WLM_FUNCTIONS_PK PRIMARY KEY (Fun_Id),
    CONSTRAINT WLM_FUNCTIONS_FK_MOD FOREIGN KEY (Mod_Id) REFERENCES ERP.WLM_MODULES(Mod_Id)
);

COMMENT ON TABLE ERP.WLM_FUNCTIONS IS 'WLM - Chức năng/tính năng';
COMMENT ON COLUMN ERP.WLM_FUNCTIONS.Current_Step IS 'LOV: WLM_WORKFLOW_STEP (BA/LED/DEV/QA/DON)';
COMMENT ON COLUMN ERP.WLM_FUNCTIONS.Status IS 'LOV: WLM_FUNCTION_STATUS (P=Pending, I=In Progress, C=Completed, R=Rejected)';
COMMENT ON COLUMN ERP.WLM_FUNCTIONS.Priority IS 'LOV: WLM_PRIORITY (L=Low, M=Medium, H=High, C=Critical)';

-- -----------------------------------------------------
-- 4. WLM_TASKS - Task phân công
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_TASKS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_TASKS (
    Tas_Id              NUMBER              NOT NULL,
    Fun_Id              NUMBER              NOT NULL,
    Assigned_To_Emp_Id  NUMBER,
    Assigned_By_Emp_Id  NUMBER,
    Task_Name           VARCHAR2(200)       NOT NULL,
    Description         VARCHAR2(4000),
    Status              VARCHAR2(1)         DEFAULT 'A',
    Start_Date          DATE,
    End_Date            DATE,
    Notes               VARCHAR2(4000),
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    Modify_Date         DATE,
    Modified_By         VARCHAR2(50),
    CONSTRAINT WLM_TASKS_PK PRIMARY KEY (Tas_Id),
    CONSTRAINT WLM_TASKS_FK_FUN FOREIGN KEY (Fun_Id) REFERENCES ERP.WLM_FUNCTIONS(Fun_Id)
);

COMMENT ON TABLE ERP.WLM_TASKS IS 'WLM - Task phân công';
COMMENT ON COLUMN ERP.WLM_TASKS.Status IS 'LOV: WLM_TASK_STATUS (A=Assigned, I=In Progress, C=Completed, B=Blocked)';

-- -----------------------------------------------------
-- 5. WLM_WORKFLOW_STEPS - Các bước workflow
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_WORKFLOW_STEPS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_WORKFLOW_STEPS (
    Wfs_Id              NUMBER              NOT NULL,
    Step_Code           VARCHAR2(3)         NOT NULL,
    Step_Name           VARCHAR2(100)       NOT NULL,
    Role_Code           VARCHAR2(3),
    Sort_Order          NUMBER              DEFAULT 0,
    Next_Step           VARCHAR2(3),
    Prev_Step           VARCHAR2(3),
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    CONSTRAINT WLM_WORKFLOW_STEPS_PK PRIMARY KEY (Wfs_Id),
    CONSTRAINT WLM_WORKFLOW_STEPS_UK UNIQUE (Step_Code)
);

COMMENT ON TABLE ERP.WLM_WORKFLOW_STEPS IS 'WLM - Các bước workflow';
COMMENT ON COLUMN ERP.WLM_WORKFLOW_STEPS.Role_Code IS 'LOV: WLM_USER_ROLE (ADM/BA/LED/DEV/QA)';

-- -----------------------------------------------------
-- 6. WLM_COMMENTS - Trao đổi/comment
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_COMMENTS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_COMMENTS (
    Com_Id              NUMBER              NOT NULL,
    Fun_Id              NUMBER,
    Tas_Id              NUMBER,
    Emp_Id              NUMBER,
    Comment_Text        VARCHAR2(4000)      NOT NULL,
    Parent_Com_Id       NUMBER,
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    CONSTRAINT WLM_COMMENTS_PK PRIMARY KEY (Com_Id),
    CONSTRAINT WLM_COMMENTS_FK_FUN FOREIGN KEY (Fun_Id) REFERENCES ERP.WLM_FUNCTIONS(Fun_Id),
    CONSTRAINT WLM_COMMENTS_FK_TAS FOREIGN KEY (Tas_Id) REFERENCES ERP.WLM_TASKS(Tas_Id),
    CONSTRAINT WLM_COMMENTS_FK_PAR FOREIGN KEY (Parent_Com_Id) REFERENCES ERP.WLM_COMMENTS(Com_Id)
);

COMMENT ON TABLE ERP.WLM_COMMENTS IS 'WLM - Trao đổi/comment';

-- -----------------------------------------------------
-- 7. WLM_USER_ROLES - Phân quyền user trong WLM
-- -----------------------------------------------------
CREATE SEQUENCE ERP.WLM_USER_ROLES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ERP.WLM_USER_ROLES (
    Usr_Id              NUMBER              NOT NULL,
    Emp_Id              NUMBER              NOT NULL,
    Role_Code           VARCHAR2(3)         NOT NULL,
    Prj_Id              NUMBER,
    Is_Active           VARCHAR2(1)         DEFAULT 'Y',
    Created_Date        DATE                DEFAULT SYSDATE,
    Created_By          VARCHAR2(50),
    Modify_Date         DATE,
    Modified_By         VARCHAR2(50),
    CONSTRAINT WLM_USER_ROLES_PK PRIMARY KEY (Usr_Id),
    CONSTRAINT WLM_USER_ROLES_FK_PRJ FOREIGN KEY (Prj_Id) REFERENCES ERP.WLM_PROJECTS(Prj_Id)
);

COMMENT ON TABLE ERP.WLM_USER_ROLES IS 'WLM - Phân quyền user trong WLM';
COMMENT ON COLUMN ERP.WLM_USER_ROLES.Role_Code IS 'LOV: WLM_USER_ROLE (ADM/BA/LED/DEV/QA)';
COMMENT ON COLUMN ERP.WLM_USER_ROLES.Is_Active IS 'Y=Active, N=Inactive';

-- =====================================================
-- PHẦN 2: GRANT QUYỀN CHO APPS
-- =====================================================

-- Grant Tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_PROJECTS TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_MODULES TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_FUNCTIONS TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_TASKS TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_WORKFLOW_STEPS TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_COMMENTS TO APPS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ERP.WLM_USER_ROLES TO APPS;

-- Grant Sequences
GRANT SELECT ON ERP.WLM_PROJECTS_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_MODULES_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_FUNCTIONS_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_TASKS_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_WORKFLOW_STEPS_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_COMMENTS_SEQ TO APPS;
GRANT SELECT ON ERP.WLM_USER_ROLES_SEQ TO APPS;

-- =====================================================
-- PHẦN 3: TẠO SYNONYMS TRÊN SCHEMA APPS
-- =====================================================

-- Kết nối vào schema APPS
-- ALTER SESSION SET CURRENT_SCHEMA = APPS;

-- Synonyms cho Tables
CREATE OR REPLACE SYNONYM APPS.WLM_PROJECTS FOR ERP.WLM_PROJECTS;
CREATE OR REPLACE SYNONYM APPS.WLM_MODULES FOR ERP.WLM_MODULES;
CREATE OR REPLACE SYNONYM APPS.WLM_FUNCTIONS FOR ERP.WLM_FUNCTIONS;
CREATE OR REPLACE SYNONYM APPS.WLM_TASKS FOR ERP.WLM_TASKS;
CREATE OR REPLACE SYNONYM APPS.WLM_WORKFLOW_STEPS FOR ERP.WLM_WORKFLOW_STEPS;
CREATE OR REPLACE SYNONYM APPS.WLM_COMMENTS FOR ERP.WLM_COMMENTS;
CREATE OR REPLACE SYNONYM APPS.WLM_USER_ROLES FOR ERP.WLM_USER_ROLES;

-- Synonyms cho Sequences
CREATE OR REPLACE SYNONYM APPS.WLM_PROJECTS_SEQ FOR ERP.WLM_PROJECTS_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_MODULES_SEQ FOR ERP.WLM_MODULES_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_FUNCTIONS_SEQ FOR ERP.WLM_FUNCTIONS_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_TASKS_SEQ FOR ERP.WLM_TASKS_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_WORKFLOW_STEPS_SEQ FOR ERP.WLM_WORKFLOW_STEPS_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_COMMENTS_SEQ FOR ERP.WLM_COMMENTS_SEQ;
CREATE OR REPLACE SYNONYM APPS.WLM_USER_ROLES_SEQ FOR ERP.WLM_USER_ROLES_SEQ;

-- =====================================================
-- PHẦN 4: INSERT MASTER DATA - WORKFLOW STEPS
-- =====================================================

INSERT INTO ERP.WLM_WORKFLOW_STEPS (Wfs_Id, Step_Code, Step_Name, Role_Code, Sort_Order, Next_Step, Prev_Step, Created_By)
VALUES (ERP.WLM_WORKFLOW_STEPS_SEQ.NEXTVAL, 'BA', 'BA Review', 'BA', 1, 'LED', NULL, 'SYSTEM');

INSERT INTO ERP.WLM_WORKFLOW_STEPS (Wfs_Id, Step_Code, Step_Name, Role_Code, Sort_Order, Next_Step, Prev_Step, Created_By)
VALUES (ERP.WLM_WORKFLOW_STEPS_SEQ.NEXTVAL, 'LED', 'Leader Assign', 'LED', 2, 'DEV', 'BA', 'SYSTEM');

INSERT INTO ERP.WLM_WORKFLOW_STEPS (Wfs_Id, Step_Code, Step_Name, Role_Code, Sort_Order, Next_Step, Prev_Step, Created_By)
VALUES (ERP.WLM_WORKFLOW_STEPS_SEQ.NEXTVAL, 'DEV', 'Development', 'DEV', 3, 'QA', 'LED', 'SYSTEM');

INSERT INTO ERP.WLM_WORKFLOW_STEPS (Wfs_Id, Step_Code, Step_Name, Role_Code, Sort_Order, Next_Step, Prev_Step, Created_By)
VALUES (ERP.WLM_WORKFLOW_STEPS_SEQ.NEXTVAL, 'QA', 'QA Testing', 'QA', 4, 'DON', 'DEV', 'SYSTEM');

INSERT INTO ERP.WLM_WORKFLOW_STEPS (Wfs_Id, Step_Code, Step_Name, Role_Code, Sort_Order, Next_Step, Prev_Step, Created_By)
VALUES (ERP.WLM_WORKFLOW_STEPS_SEQ.NEXTVAL, 'DON', 'Done', 'BA', 5, NULL, 'QA', 'SYSTEM');

COMMIT;

-- =====================================================
-- END OF SCRIPT
-- =====================================================

