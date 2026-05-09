# LearnHub - Online Learning Platform

A modern, feature-rich online learning platform built with ASP.NET Core 9 and Entity Framework Core.

## Features

### 🎓 Core Learning Features
- **Course Management**: Browse, search, and enroll in courses across multiple categories
- **Curriculum System**: Full management of course modules and lessons (Text/Video content)
- **Learning Paths**: Structured learning journeys with curated course sequences
- **Progress Tracking**: Track your learning progress across courses and lessons
- **Assessment System**: Skill assessment questionnaire for personalized recommendations
- **User Dashboard**: Personal learning dashboard with enrollments and progress

### ⚡ Real-time & Administrative Features
- **Real-time Updates**: Instant synchronization of course statuses (Publish/Suspend) via SignalR
- **Live Curriculum Editing**: Real-time feedback when managing course modules and lessons
- **Administrative Dashboard**: Comprehensive stats and management tools for admins
- **Broadcasting Architecture**: Decoupled SignalR broadcasting for clean service-layer integration

### 💰 E-commerce Features
- **Order Management**: Complete order history and transaction tracking
- **Payment Integration**: Ready for payment gateway integration (VnPay supported)
- **Course Enrollment**: Automatic enrollment upon successful payment

### 👤 User Management
- **Authentication & Authorization**: Secure login/logout with cookie authentication
- **Role-based Access**: Different roles for Users, Instructors, and Admins
- **User Profiles**: Personalized user profiles and settings

### ✨ Modern UI/UX
- **Responsive Design**: Mobile-first responsive design
- **Modern Components**: Beautiful, accessible UI components with Bootstrap 5
- **Real-time Toasts**: Instant UI feedback for administrative actions
- **Performance Optimized**: Fast loading with optimized assets

## Technology Stack

- **Framework**: ASP.NET Core 9 with Razor Pages
- **Real-time**: ASP.NET Core SignalR
- **Database**: Entity Framework Core (SQL Server / In-Memory support)
- **Authentication**: Cookie-based Authentication
- **Frontend**: Bootstrap 5, Vanilla JavaScript, SignalR Client
- **Architecture**: Clean Architecture with Service Layer and Repository pattern

## Quick Start

### Prerequisites
- .NET 9 SDK
- Visual Studio 2022 or VS Code

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Online-Learning-Platform-Ass2
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Build the solution**
   ```bash
   dotnet build
   ```

4. **Run the application**
   ```bash
   cd OnlineLearningPlatformAss2.RazorWebApp
   dotnet run
   ```

5. **Open in browser**
   Navigate to `https://localhost:7049` or the URL shown in the terminal

### Default Test User
- **Username**: `admin`
- **Email**: `admin@learnhub.com`
- **Password**: `admin123` (or seeded admin account)

## Project Structure

```
├── OnlineLearningPlatformAss2.RazorWebApp/     # Main web application
│   ├── Pages/                                   # Razor Pages
│   ├── Hubs/                                    # SignalR Hubs (Pure Contracts)
│   ├── Services/                                # Web-specific Services (Broadcasters)
│   └── wwwroot/                                 # Static files (CSS, JS, images)
├── OnlineLearningPlatformAss2.Service/         # Business logic layer
│   ├── Services/                                # Service implementations
│   ├── DTOs/                                    # Data Transfer Objects
│   └── Interfaces/                              # Service interfaces
└── OnlineLearningPlatformAss2.Data/            # Data access layer
    ├── Database/                                # Entity Framework context
    ├── Entities/                                # Database entities
    └── Repositories/                            # Repository implementations
```

## Key Features Guide

### 1. Course & Curriculum Management (Admin)
- Admins can create and edit courses through the management dashboard.
- **Curriculum Editor**: Add modules and lessons to any course. 
- **Real-time Sync**: Actions like suspending or updating a course are broadcasted instantly to all browsing students.

### 2. Skill Assessment
- Take the skill assessment from the navigation menu to get personalized recommendations.
- Recommendations are updated live based on your assessment results.

### 3. Learning Paths
- Browse curated paths to master specific technology stacks.
- Progress is tracked cumulatively across all courses in the path.

### 4. Learning Experience
- Student-facing lessons support both rich text content and embedded videos.
- Progress is automatically saved as you navigate through the curriculum.

## Development Notes

### SignalR Implementation
The project uses a pure hub contract pattern. Business logic resides in `AdminService`, which triggers updates via `ICourseUpdateBroadcaster`. This allows for a clean separation of concerns where SignalR is strictly for real-time communication.

### Database
- Supports both SQL Server and In-Memory Database for ease of development.
- Automatically seeds categories, users, and initial courses on first run.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is for educational purposes. 

## Support

For issues or questions, please create an issue in the repository.

---

**LearnHub** - Empowering learning through technology 🚀
