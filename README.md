
# 🏠 Dorm of Decents

A comprehensive dorm management system built with Flutter and Dart. Track meals, expenses, settlements, and manage user activities in shared living spaces. Cross-platform support for Android, iOS, Windows, macOS, and Linux.

![Flutter](https://img.shields.io/badge/Flutter-3.16-blue)
![Dart](https://img.shields.io/badge/Dart-3.2-blue)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20DB-yellow)
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
- [Additional Docs](#-additional-docs)

---

## ✨ Features

### 🔐 Authentication & Security
- Secure login system (Firebase/Supabase)
- Password reset via email with OTP
- Rate limiting on password reset
- Session management with token refresh

### 👥 User Management
- Two user roles: Admin and Member
- Profile management (name, phone)
- Activity logging for user actions
- User creation/editing (Admin only)

### 🍽️ Meal Tracking
- Daily meal entry (supports fractional meals)
- Month-wise meal tracking
- Individual meal history
- Total meals calculation per month
- Meal cost calculation based on expenses

### 💰 Expense Management
- Multi-category expenses: Food, Electricity, Internet, Gas, Miscellaneous
- Expense entry with date, amount, description
- Expense history with category filtering
- Total expense calculation per month
- Per-user expense tracking

### 📊 Monthly Settlements
- Automatic settlement calculation:
	- Total meals per user
	- Meal cost per unit
	- Amount paid/owed/received
- Settlement status (Settled/Pending)
- Month management (Active/Closed)
- Historical data for past months

### 📈 Dashboard & Analytics
- Overview dashboard with key metrics
- Visual charts for meals and expenses
- Recent activity feed
- Quick actions for common tasks
- Real-time data updates

### 🎨 UI/UX Features
- Dark/Light mode toggle
- Responsive design for mobile and desktop
- Modern UI with frosted glass effects
- Skeleton loading states
- Toast notifications
- Smooth animations

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.16
- **Language:** Dart 3.2
- **State Management:** Bloc/Cubit
- **Database:** Firebase/Supabase/PostgreSQL
- **Authentication:** Firebase/Supabase Auth
- **Charts:** fl_chart
- **UI Components:** Custom Widgets, Material Design

---

## 👥 User Roles & Permissions

### 🔑 Admin
Admins have full control:
- Create/edit users
- Manage months
- Add/edit/delete meals and expenses
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

---

## 📚 Additional Docs

- [Password Reset Guide](./PASSWORD_RESET_GUIDE.md)
- [Logs Setup](./LOGS_SETUP.md)
- [Setup Guide](./SETUP_GUIDE.md)

**Made with ❤️ for better dorm management**
