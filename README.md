# 📱 Flutter Request Handling Workflow Application

A full-stack mobile application built with Flutter and Node.js that implements a real-world request and confirmation workflow system with dual-role functionality.

## 🎯 Project Overview

This application solves the challenge of managing item requests between end users and receivers in a structured workflow. It implements a complete system where end users can submit requests for multiple items, and receivers can review and process these requests item by item, with real-time status updates and partial fulfillment capabilities.

## 🏗️ System Architecture

### Frontend (Flutter)
- **Framework**: Flutter with Dart
- **State Management**: Riverpod for reactive state management
- **UI Framework**: Material Design 3 with adaptive theming
- **Real-time Communication**: WebSocket integration with fallback polling
- **Authentication**: JWT-based role authentication

### Backend (Node.js)
- **Runtime**: Node.js with Express.js
- **Database**: MongoDB for data persistence
- **Real-time**: WebSocket server for live updates
- **Authentication**: JWT tokens with bcrypt password hashing
- **API**: RESTful endpoints with proper error handling

## 🚀 Features Implemented

### ✅ End User Role
- **Request Creation**: Select multiple items with quantities and submit requests
- **Status Tracking**: Real-time view of request statuses (Pending, Confirmed, Partially Fulfilled)
- **Request History**: Complete history with detailed item breakdowns
- **Progress Monitoring**: Live updates when receivers process items
- **Navigation**: Seamless navigation to request details and completed requests

### ✅ Receiver Role
- **Request Review**: View all assigned pending requests with priority sorting
- **Item-by-Item Processing**: Individual item confirmation with status options:
  - Fulfilled
  - Reassigned (with reason and receiver selection)
  - Out of Stock
- **Reassignment System**: Transfer unconfirmed items to other receivers
- **Batch Operations**: Quick approve/reject all items functionality
- **Notes System**: Add reassignment reasons and processing notes

### ✅ Advanced Features
- **Real-time Updates**: WebSocket-powered live synchronization
- **Offline Support**: Graceful handling of network interruptions
- **Error Recovery**: Robust error handling with retry mechanisms
- **Responsive Design**: Adaptive UI for different screen sizes
- **Dark/Light Theme**: System-adaptive theming support
- **Performance Optimization**: Efficient state management and API calls

## 📱 User Interface Highlights

### Design Principles
- **Material Design 3**: Modern, accessible interface components
- **Contrast Optimization**: Enhanced visibility in both light and dark modes
- **Touch-Friendly**: Proper spacing and touch targets
- **Navigation**: Intuitive tab-based navigation with role-specific screens
- **Visual Feedback**: Loading states, animations, and status indicators

### Key UI Components
- **Gradient Header Cards**: Enhanced visual hierarchy for requests
- **Interactive Request Cards**: Clickable items with visual feedback
- **Status Indicators**: Color-coded status badges with icons
- **Form Controls**: Accessible dropdowns and input fields
- **Action Buttons**: Prominent CTAs with proper states

## 🔧 Technical Implementation

### State Management Architecture
```dart
// Riverpod Provider Pattern
final authProvider = StateNotifierProvider<AuthProvider, User>((ref) => AuthProvider());
final requestsProvider = StateNotifierProvider<RequestsProvider, List<Request>>((ref) => RequestsProvider());
```

### Real-time Communication
```dart
// WebSocket Integration
class SocketService {
  void connectToServer({required WidgetRef ref}) {
    // WebSocket connection with automatic reconnection
    // Queue-based message handling for reliability
    // Provider updates for real-time state synchronization
  }
}
```

### Authentication Flow
```dart
// JWT-based Authentication
class AuthProvider extends StateNotifier<User> {
  // Loading state management to prevent login flash
  // Secure token storage and validation
  // Role-based access control
}
```

## 🔗 API Endpoints

### Authentication
- `POST /auth/login` - User authentication
- `POST /auth/register` - User registration

### Requests Management
- `GET /api/requests` - Fetch user requests
- `POST /api/requests` - Create new request
- `PUT /api/requests/:id` - Update request status

### Items & Receivers
- `GET /api/items` - Fetch available items
- `GET /api/receivers` - Fetch available receivers
- `POST /api/reassign` - Reassign items to receivers

### Real-time
- `WebSocket /socket` - Real-time updates channel

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (≥3.0.0)
- Node.js (≥16.0.0)
- MongoDB (≥4.4)
- VS Code with Flutter extension (recommended)

### Backend Setup
```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your MongoDB connection string refer  

# Start the server
node index.js
# Server runs on http://localhost:3000
```

### Flutter App Setup
```bash
# Navigate to app directory
cd request_app

# Install dependencies
flutter pub get

# Run the application
flutter run
# Select your target device (Android/iOS/Web)
```

### Database Setup
```bash
# Start MongoDB service
mongod

# The application will automatically create required collections
# Demo data can be created using the provided script:
node server/scripts/create_demo.js
```

## 🎮 Usage Workflow

### End User Journey
1. **Login**: Authenticate as end user
2. **Create Request**: Select items and quantities
3. **Submit**: Send request to system
4. **Monitor**: Track real-time status updates
5. **Review**: View completed and partial fulfillments

### Receiver Journey
1. **Login**: Authenticate as receiver
2. **Review Queue**: View pending requests
3. **Process Items**: Confirm availability item by item
4. **Handle Reassignments**: Transfer items to other receivers
5. **Submit Changes**: Complete request processing

## 🔄 Data Flow Architecture

```
End User → Request Creation → Backend API → Database Storage
                ↓
WebSocket Notification → Receiver Interface
                ↓
Item Processing → Status Updates → Real-time Sync
                ↓
Partial/Complete Fulfillment → End User Notification
```

## 🧪 Key Problem Solutions

### 1. Real-time Updates Without Firebase
**Problem**: Need live updates without external services
**Solution**: Custom WebSocket implementation with message queuing and automatic reconnection

### 2. Partial Request Fulfillment
**Problem**: Handle scenarios where only some items are available
**Solution**: Item-level status tracking with reassignment workflow

### 3. Authentication State Management
**Problem**: Login screen flashing during app startup
**Solution**: Loading state pattern with proper initialization lifecycle

### 4. UI Contrast & Accessibility
**Problem**: Poor visibility in dark mode
**Solution**: Dynamic color schemes with proper contrast ratios

### 5. Offline Handling
**Problem**: Network interruptions breaking functionality
**Solution**: Queue-based operations with retry mechanisms

## 📊 Performance Optimizations

- **Efficient State Updates**: Minimal rebuilds with targeted provider updates
- **Memory Management**: Proper disposal of controllers and listeners
- **Network Optimization**: Request deduplication and caching
- **UI Responsiveness**: Non-blocking operations with proper loading states

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Role-based Access**: Proper permission validation
- **Password Hashing**: bcrypt for secure password storage
- **Input Validation**: Server-side validation for all inputs

## 🎯 Achievement Summary

### ✅ Core Requirements Met
- [x] Dual-role functionality (End User & Receiver)
- [x] Item-by-item confirmation workflow
- [x] Partial fulfillment with reassignment
- [x] Real-time updates without Firebase
- [x] Backend API with proper endpoints
- [x] Clean state management with Riverpod
- [x] Professional UI/UX design
- [x] Comprehensive error handling

### ✅ Advanced Features Added
- [x] WebSocket real-time communication
- [x] Dark/Light theme support
- [x] Offline capability with queue management
- [x] Enhanced accessibility and contrast
- [x] Comprehensive documentation
- [x] Demo data creation scripts

## 🎬 Demo Video

A comprehensive demo video showcasing the complete workflow is available in the project repository, demonstrating:
- End user request creation and submission
- Receiver request processing and item confirmation
- Real-time status updates and notifications
- Partial fulfillment and reassignment workflow
- Error handling and recovery scenarios

## 🤝 Contributing

This project demonstrates enterprise-level Flutter development practices and can serve as a reference for similar workflow applications. The modular architecture allows for easy extension and customization.

## 📄 License

This project is part of a Flutter internship assignment and is intended for educational and demonstration purposes.

---

**Built with ❤️ using Flutter & Node.js**