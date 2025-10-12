# A11yPal Django Backend

A comprehensive Django REST API backend for the A11yPal accessibility mobile application.

## 🚀 Features

### User Management
- User registration and authentication
- User profiles with accessibility preferences
- Emergency contact management
- Privacy settings and data control

### Visual Assistance
- Image analysis and object detection
- OCR text recognition
- Scene description generation
- Color analysis for accessibility
- Face detection capabilities

### Hearing Assistance
- Speech-to-text transcription
- Noise detection and analysis
- Volume level analysis
- Frequency spectrum analysis
- Hearing aid settings management

### Mobility Assistance
- Location tracking and management
- Accessible location database
- Navigation route planning
- Obstacle reporting system
- Emergency alert system

### History & Analytics
- Activity logging and tracking
- Usage statistics and analytics
- Error logging and monitoring
- User feedback system
- Data export functionality

## 🛠️ Installation

### Prerequisites
- Python 3.8+
- pip
- SQLite (default) or PostgreSQL/MySQL

### Setup

1. **Navigate to the backend directory:**
   ```bash
   cd a11ypal_backend
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run migrations:**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

4. **Create a superuser:**
   ```bash
   python manage.py createsuperuser
   ```

5. **Start the development server:**
   ```bash
   python manage.py runserver
   ```

The API will be available at `http://localhost:8000/`

## 📚 API Endpoints

### Authentication
- `POST /api/users/register/` - User registration
- `POST /api/users/login/` - User login
- `POST /api/users/logout/` - User logout

### User Management
- `GET /api/users/profile/` - Get user profile
- `PUT /api/users/profile/` - Update user profile
- `GET /api/users/profile/settings/` - Get accessibility settings
- `PUT /api/users/profile/settings/` - Update accessibility settings
- `GET /api/users/dashboard/` - Get user dashboard data

### Visual Assistance
- `POST /api/visual-assist/analyze/` - Analyze image
- `POST /api/visual-assist/extract-text/` - Extract text from image
- `POST /api/visual-assist/describe-scene/` - Describe scene in image
- `POST /api/visual-assist/analyze-colors/` - Analyze colors for accessibility
- `GET /api/visual-assist/analyses/` - List image analyses
- `GET /api/visual-assist/stats/` - Get usage statistics

### Hearing Assistance
- `POST /api/hearing-assist/transcribe/` - Transcribe audio to text
- `POST /api/hearing-assist/detect-noise/` - Detect noise in audio
- `POST /api/hearing-assist/analyze-volume/` - Analyze audio volume
- `POST /api/hearing-assist/analyze-frequency/` - Analyze audio frequency
- `GET /api/hearing-assist/speech-to-text/` - List transcriptions
- `GET /api/hearing-assist/hearing-aid-settings/` - Get hearing aid settings
- `PUT /api/hearing-assist/hearing-aid-settings/` - Update hearing aid settings

### Mobility Assistance
- `POST /api/mobility-assist/update-location/` - Update user location
- `GET /api/mobility-assist/nearby-accessible/` - Find nearby accessible locations
- `POST /api/mobility-assist/create-route/` - Create navigation route
- `POST /api/mobility-assist/report-obstacle/` - Report accessibility obstacle
- `POST /api/mobility-assist/create-emergency-alert/` - Create emergency alert
- `GET /api/mobility-assist/accessible-locations/` - List accessible locations
- `GET /api/mobility-assist/emergency-contacts/` - Manage emergency contacts

### History & Analytics
- `POST /api/history/log-activity/` - Log user activity
- `GET /api/history/dashboard/` - Get usage dashboard
- `POST /api/history/submit-feedback/` - Submit user feedback
- `POST /api/history/request-export/` - Request data export
- `GET /api/history/feature-analytics/` - Get feature analytics
- `GET /api/history/error-analytics/` - Get error analytics

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the project root:

```env
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
```

### CORS Settings
The API is configured to allow requests from:
- `http://localhost:3000` (React Native Web)
- `http://localhost:8081` (Expo)
- `http://localhost:8082` (Alternative Expo port)

## 📊 Database Models

### User Models
- `User` - Extended user model with accessibility fields
- `UserProfile` - User accessibility preferences and settings

### Visual Assist Models
- `ImageAnalysis` - Image analysis results
- `TextRecognition` - OCR text extraction
- `ObjectDetection` - Object detection results
- `SceneDescription` - AI-generated scene descriptions
- `ColorAnalysis` - Color accessibility analysis

### Hearing Assist Models
- `AudioAnalysis` - Audio analysis results
- `SpeechToText` - Speech transcription
- `NoiseDetection` - Noise analysis
- `VolumeAnalysis` - Volume level analysis
- `FrequencyAnalysis` - Frequency spectrum analysis
- `HearingAidSettings` - User hearing aid preferences

### Mobility Assist Models
- `LocationData` - User location tracking
- `AccessibilityLocation` - Accessible location database
- `NavigationRoute` - Navigation routes
- `ObstacleReport` - Accessibility obstacle reports
- `EmergencyContact` - Emergency contacts
- `EmergencyAlert` - Emergency alerts

### History Models
- `ActivityLog` - User activity logging
- `UsageStatistics` - Usage analytics
- `FeatureUsage` - Feature usage tracking
- `ErrorLog` - Error logging
- `UserFeedback` - User feedback
- `DataExport` - Data export requests
- `PrivacySettings` - Privacy preferences

## 🔐 Authentication

The API uses Django REST Framework's token authentication. Include the token in the Authorization header:

```
Authorization: Token your-token-here
```

## 📱 Mobile App Integration

The backend is designed to work seamlessly with the React Native mobile app. Key integration points:

1. **Authentication**: Token-based authentication for secure API access
2. **File Uploads**: Support for image and audio file uploads
3. **Real-time Data**: Location tracking and emergency alerts
4. **Offline Support**: Cached data and sync capabilities
5. **Privacy**: Comprehensive privacy controls and data export

## 🚀 Deployment

### Production Settings
1. Set `DEBUG=False`
2. Configure proper database (PostgreSQL recommended)
3. Set up static file serving
4. Configure CORS for production domains
5. Set up SSL/HTTPS
6. Configure proper logging

### Docker Deployment
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

## 📈 Monitoring

The API includes comprehensive logging and monitoring:
- Activity logging for all user actions
- Error tracking and reporting
- Usage analytics and statistics
- Performance monitoring
- Privacy compliance tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔮 Future Enhancements

- Real-time AI processing
- Advanced analytics dashboard
- Machine learning recommendations
- Integration with external accessibility services
- Mobile push notifications
- Offline data synchronization
