
# 🏠 Dorm of Decents

A comprehensive bachelors flat management application built with Flutter. Track meals, expenses, bills, settlements, and manage user activities in shared living spaces. Cross-platform support for Android, iOS, Windows, macOS, and Linux.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue)
![Dart](https://img.shields.io/badge/Dart-3.2+-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![Responsive](https://img.shields.io/badge/Responsive-UI-green)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [User Roles & Permissions](#-user-roles--permissions)
- [How It Works](#-how-it-works)
- [Installation](#-installation)
- [Database Schema](#-database-schema)
- [Authentication Flow](#-authentication-flow)
- [Project Structure](#-project-structure)
- [Deployment](#-deployment)
- [Developer](#-developer)

---

## ✨ Features

### 🔐 Authentication & Security
- Secure login system with Supabase Auth
- Session management with automatic token refresh
- Role-based access control (Admin/Member)
- Activity logging for audit trails

### 👥 User Management
- Two user roles: Admin and Member
- Profile management with avatars
- User creation and editing (Admin only)
- Activity tracking per user
- Real-time user status

### 🍽️ Meal Tracking
- Daily meal entry with fractional support (0.5, 1.0, 1.5, etc.)
- Month-wise meal tracking
- Individual meal history with filtering
- **Downloadable meal reports** (PNG format)
- Meal cost calculation based on total expenses
- Pull-to-refresh data sync

### 💰 Expense Management
- Multi-category expenses: Food, Electricity, Internet, Gas, Miscellaneous
- Expense entry with date, amount, and description
- **Downloadable expense reports** (PNG format)
- Expense history with category filtering
- Total expense calculation per month
- Per-user contribution tracking

### 🧾 Bill Management
- Track utility bills (Electricity, Gas, Internet)
- Bill payment tracking by user
- **Downloadable bill reports** (PNG format)
- Bill type categorization
- Monthly bill summaries

### 💸 Bills Due & Repayment System
- **Smart bill splitting** - Automatically divides bills among active members
- **Repayment tracking** - Record when members pay their share
- **Visual status indicators**:
  - 🟢 Gets Back (member receives money)
  - 🔴 Owes (member needs to pay)
  - 🔵 Settled (all balanced)
- Per-bill breakdown showing:
  - Who paid the bill
  - Amount per person
  - Individual payment status
- Admin-only repayment recording with validation
- Activity logging for all transactions

### 📅 Month Management
- View all billing cycles
- Active/Closed status with visual indicators
- Start and end date display
- Month creation and status management
- Historical month data access

### 📊 Dashboard & Analytics
- Overview dashboard with key metrics:
  - Meal rate per unit
  - Total meals consumed
  - Total expenses
  - Total bills
  - Weekly trends
  - Days active
  - Active member count
- Expense breakdown by category
- Category distribution charts
- Top meal consumers
- Top expense contributors
- Recent transaction feed
- Real-time data updates
- **Static AppBar** - Optimized to prevent unnecessary reloads

### 📝 Activity Logs
- Comprehensive audit trail
- Timestamped entries
- User action tracking
- Admin activity monitoring

### 🎨 UI/UX Features
- Dark/Light mode support (system-based)
- Responsive design for all screen sizes
- Modern Material 3 design
- **Crimson Text font** for headers/titles
- **Geist font** for body text
- Skeleton loading states
- Toast notifications with icons
- Smooth page transitions
- Pull-to-refresh functionality
- Custom widgets and components
- Drawer navigation
- Bottom navigation bar

### 📱 Report Generation
All reports are generated as PNG images and saved to:
- **Android**: Downloads folder
- **iOS**: App documents directory

Features:
- User-specific data filtering
- Date-based grouping
- Total calculations
- Professional formatting
- One-click download

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.16+
- **Language:** Dart 3.2+
- **State Management:** flutter_bloc (Cubit pattern)
- **Backend:** Supabase (PostgreSQL + Auth)
- **Database:** PostgreSQL via Supabase
- **Authentication:** Supabase Auth
- **Routing:** go_router
- **UI Components:** Material 3, Custom Widgets
- **Fonts:** Crimson Text (headers), Geist (body)
- **Report Generation:** RepaintBoundary, RenderRepaintBoundary
- **File Handling:** path_provider
- **Date Formatting:** intl
- **Notifications:** toastification

### Key Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  supabase_flutter: ^2.0.0
  go_router: ^13.0.0
  toastification: ^2.0.0
  intl: ^0.19.0
  path_provider: ^2.1.2
```

---

## 👥 User Roles & Permissions

### 🔑 Admin
Admins have full control:
- Create/edit/delete users
- Manage months (create, open, close)
- Add/edit/delete meals and expenses
- Add/edit bills
- **Record bill repayments** for any user
- View/download all reports
- Access complete activity logs
- View all analytics and dashboards
- Manage settlements

### 👤 Member
Members have standard access:
- Add/edit own meals and expenses
- View own settlement status
- View bills due and payment status
- Download own reports
- View personal stats
- Access limited dashboard data
- Cannot manage other users or months
- Cannot record repayments (admin only)

---

## 🔄 How It Works

### Standard Monthly Cycle

1. **Admin creates a new month**
   - Sets start and end dates
   - Month status: Active

2. **Users are added/activated**
   - Admin assigns members to the month
   - Users can now log activities

3. **Members log daily activities**
   - Record meals consumed
   - Add shared expenses
   - Pay utility bills

4. **Bills Due System**
   - Admin logs utility bills (paid by one person)
   - System calculates per-person share
   - Members see their dues
   - Admin records repayments as they occur
   - Real-time balance tracking

5. **Admin closes month**
   - Month status: Closed
   - Final settlement calculated

6. **Settlement Distribution**
   - System calculates who owes/receives
   - Based on meals consumed vs expenses paid

### Bills Due Example

**Scenario**: Electricity bill of ৳3,000 paid by Alice for 4 active members

| Member | Share | Paid  | Status      |
|--------|-------|-------|-------------|
| Alice  | ৳750  | ৳750  | Settled ✓   |
| Bob    | ৳750  | ৳0    | Owes ৳750   |
| Carol  | ৳750  | ৳500  | Owes ৳250   |
| David  | ৳750  | ৳750  | Settled ✓   |

**Result**: Alice receives ৳1,500 back (Bob's ৳750 + Carol's ৳250)
- View/mark settlements
- Access logs and analytics

### 👤 Member
Members have limited access:
- Add/edit own meals and expenses
- View personal settlement and stats
- Cannot manage other users or months

---

## 🔄 How It Works

1. **Admin creates a new month**
2. **Users are added**
3. **Members log daily meals and expenses**
4. **System tracks entries**
5. **Admin closes month for settlement**
6. **System calculates settlements**

**Example Settlement Table:**

| User  | Meals | Meal Cost | Expenses Paid | Settlement         |
|-------|-------|-----------|--------------|--------------------|
| Alice | 50    | ₹2,000    | ₹3,500       | Receives ₹1,500    |
| Bob   | 60    | ₹2,400    | ₹2,000       | Pays ₹400          |
| Carol | 45    | ₹1,800    | ₹2,500       | Receives ₹700      |
| David | 95    | ₹3,800    | ₹2,000       | Pays ₹1,800        |

---

## 📦 Installation

### Prerequisites
- Flutter SDK 3.16+
- Dart 3.2+
- Firebase/Supabase account

### Step 1: Clone & Install
```pwsh
git clone https://github.com/yourusername/dorm_of_decents.git
cd dorm_of_decents
flutter pub get
```

### Step 2: Environment Setup
- Configure Firebase/Supabase in `lib/app/configs/environments.dart`
- Add API keys and URLs

### Step 3: Run App
```pwsh
flutter run
```
Or select your target device in VS Code.

---

## 🗄️ Database Schema

- **profiles**: User info (id, name, phone, role)
- **months**: Billing periods (id, name, dates, status)
- **meals**: Daily meal entries (id, user_id, month_id, date, count)
- **expenses**: Shared expenses (id, month_id, category, amount, date)
- **settlements**: Per-user/month calculations
- **logs**: Activity audit trail

---

## 🔐 Authentication Flow

- Login: Email/Password → Auth → Session → Dashboard
- Password Reset: Email OTP → Reset → Login

---

## 📁 Project Structure

```
lib/
├── main.dart
├── app/
│   ├── configs/      # App configs, assets, routes, theme
│   ├── data/         # Models, services
│   ├── logic/        # Cubits, state management
│   ├── ui/           # Pages, widgets
│   └── utils/        # Utilities
assets/
├── fonts/
└── images/
test/
```

---

## 🚀 Deployment

- Build for Android/iOS: `flutter build apk` / `flutter build ios`
- Desktop: `flutter build windows` / `flutter build macos` / `flutter build linux`
- Web: `flutter build web`

---

## 👨‍💻 Developer

**Kaium Al Limon**
- WhatsApp: [+8801738439423](https://wa.me/+8801738439423)
- Contact for account creation/updates
