# OVI-APEX

Oracle APEX Applications - Core Business Modules

## 📋 Mô tả

Repository chứa tất cả ứng dụng APEX của OVI ERP System, được tổ chức theo cấu trúc:
**APEX → Công ty → Module → Sub-module → Page**

## 🏗️ Cấu trúc

```
OVI-APEX/
├── Company_A/
│   ├── HCM/                    # Human Capital Management
│   │   ├── Recruitment/
│   │   ├── Employee_Management/
│   │   └── Payroll/
│   ├── PJM/                    # Project Management
│   ├── PMM/                    # Performance Management
│   ├── FCM/                    # Financial & Facility Management
│   ├── CRM/                    # Customer Relationship Management
│   └── WLM/                    # Workflow Management
└── shared/                     # Company-specific shared components
```

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/ovidevteam/OVI-APEX.git

# Clone dependencies
git clone https://github.com/ovidevteam/OVI-APEX-SHARED.git
git clone https://github.com/ovidevteam/OVI-STANDARDS.git
```

## 📚 Documentation

- [Repository Structure](https://github.com/ovidevteam/OVI-DOCS)
- [Coding Standards](https://github.com/ovidevteam/OVI-STANDARDS)
- [Setup Guide](https://github.com/ovidevteam/OVI-DOCS/00-INDEX/QUICK-START.md)

## 👥 Team

- **HCM Team**: HCM module
- **PJM Team**: PJM module
- **PMM Team**: PMM module
- **Lead**: All modules

## 📝 License

Proprietary - OVI Group © 2025

