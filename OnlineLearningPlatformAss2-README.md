# OnlineLearningPlatformAss2 - Razor Pages Edition

An ASP.NET Core Razor Pages web application for online learning management, focusing on real-time curriculum management and clean architecture.

## 🚀 Key Features

- **Real-time Course Management**: Publish/Suspend/Update courses with instant notification to students.
- **Curriculum System**: Structured management of modules and lessons with video and text support.
- **SignalR Broadcasting**: Decoupled broadcasting pattern allowing services to push real-time updates without direct hub dependency.
- **Clean Layers**: 3-tier architecture (Web, Service, Data) with repository and broadcast abstractions.

## 🛠️ Technology Stack

- **.NET 9.0** - Core framework
- **ASP.NET Core Razor Pages** - Frontend rendering
- **SignalR** - Real-time communication (Server-to-client)
- **Entity Framework Core** - ORM support for SQL Server and In-Memory
- **Bootstrap 5** - Modern UI styling

## 📂 Project Structure

```
OnlineLearningPlatformAss2/
├── OnlineLearningPlatformAss2.RazorWebApp/     # Presentation Layer
│   ├── Pages/                                   # Razor Pages (UI)
│   ├── Hubs/                                    # SignalR Hub Contracts
│   ├── Services/                                # SignalR Broadcasters
│   └── wwwroot/                                 # Static Assets (SignalR.js, etc.)
├── OnlineLearningPlatformAss2.Service/         # Business Logic Layer
│   ├── Services/                                # Business Logic & Orchestration
│   ├── DTOs/                                    # Data Transfer Objects
│   └── Interfaces/                              # Service & Broadcaster Interfaces
└── OnlineLearningPlatformAss2.Data/            # Data Access Layer
    ├── Database/                                # EF Core Context
    ├── Entities/                                # Domain Entities
    └── Repositories/                            # Data Access Pattern
```

## 🏗️ Technical Architecture

### Real-time Broadcasting Pattern
The application implements a decoupled SignalR pattern:
1. **ICourseClient**: Defines the client-side contract.
2. **ICourseUpdateBroadcaster**: Service-layer interface for pushing updates.
3. **SignalRCourseUpdateBroadcaster**: RazorWebApp implementation that uses `IHubContext` to reach clients.
4. **AdminService**: Consumes the broadcaster interface; it doesn't need to know about SignalR Hubs directly.

## 🔨 Quick Start

1. **Restore & Build**:
   ```bash
   dotnet restore
   dotnet build
   ```

2. **Database Update** (if not using In-Memory):
   ```bash
   dotnet ef database update --project OnlineLearningPlatformAss2.Data --startup-project OnlineLearningPlatformAss2.RazorWebApp
   ```

3. **Run**:
   ```bash
   cd OnlineLearningPlatformAss2.RazorWebApp
   dotnet run
   ```
