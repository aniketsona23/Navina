# Backend Configuration Guide

This guide explains how to configure the backend URL for the Nayati Flutter app to work with your team's setup.

## Quick Setup (Recommended)

### Option 1: Use the App Settings (Easiest)
1. Open the app and go to **Settings**
2. Scroll down to **Backend Configuration**
3. Choose one of the predefined options:
   - **Auto-detect**: Automatically finds the best backend URL
   - **Team Network**: Uses the team's network backend (10.30.8.17)
   - **Local Development**: Connects to localhost (for local testing)
   - **Custom**: Enter your specific IP address

### Option 2: Environment Variables (For Developers)

#### Using Dart Define (Recommended for Flutter)
```bash
# Run the app with a custom backend URL
flutter run --dart-define=BACKEND_URL=http://YOUR_IP:8000/api

# Example:
flutter run --dart-define=BACKEND_URL=http://192.168.1.100:8000/api
```

#### Using System Environment Variables
```bash
# Windows (Command Prompt)
set BACKEND_URL=http://YOUR_IP:8000/api
flutter run

# Windows (PowerShell)
$env:BACKEND_URL="http://YOUR_IP:8000/api"
flutter run

# macOS/Linux
export BACKEND_URL=http://YOUR_IP:8000/api
flutter run
```

## Finding Your Backend IP Address

### If you're running the Django backend:
1. **Find your local IP**:
   ```bash
   # Windows
   ipconfig
   
   # macOS/Linux
   ifconfig
   # or
   ip addr show
   ```

2. **Start Django with network access**:
   ```bash
   cd a11ypal_backend
   python manage.py runserver 0.0.0.0:8000
   ```

3. **Use your IP address**: `http://YOUR_IP:8000/api`

### If you're connecting to a team member's backend:
Ask them for their IP address and use: `http://THEIR_IP:8000/api`

## Configuration Priority

The app checks for backend URLs in this order:
1. **User preference** (saved in app settings)
2. **Dart define environment variable** (`--dart-define=BACKEND_URL=...`)
3. **System environment variable** (`BACKEND_URL`)
4. **Auto-detection** (tries team network first, then localhost)
5. **Localhost fallback** (`http://localhost:8000/api`)

## Common Configurations

### Team Development Setup
```bash
# Use the team's shared backend
flutter run --dart-define=BACKEND_URL=http://10.30.8.17:8000/api
```

### Individual Development Setup
```bash
# Use your own backend
flutter run --dart-define=BACKEND_URL=http://192.168.1.100:8000/api
```

### Local Testing Setup
```bash
# Use localhost (backend running on same machine)
flutter run --dart-define=BACKEND_URL=http://localhost:8000/api
```

## Troubleshooting

### Connection Issues
1. **Check if backend is running**:
   ```bash
   curl http://YOUR_IP:8000/api/health/
   ```

2. **Verify network connectivity**:
   - Make sure both devices are on the same network
   - Check firewall settings
   - Try pinging the backend IP

3. **Use the app's connection test**:
   - Go to Settings → Backend Configuration
   - Tap "Test & Save" to verify the connection

### Common Error Messages
- **"Connection failed"**: Backend not running or wrong IP
- **"Timeout"**: Network connectivity issues or firewall blocking
- **"Refused connection"**: Backend not accepting connections on the specified port

## Best Practices

### For Team Leads
1. **Share a consistent setup**: Use the same IP address for team development
2. **Document your backend URL**: Update this guide with your team's IP
3. **Use environment variables**: Set up `.env` files or scripts for easy switching

### For Team Members
1. **Test your connection**: Always test before starting development
2. **Use auto-detect first**: Try the auto-detect option before manual configuration
3. **Keep settings updated**: Update your configuration if the backend moves

## Advanced Configuration

### Using .env Files (Optional)
Create a `.env` file in your project root:
```env
BACKEND_URL=http://10.30.8.17:8000/api
```

Then load it in your development environment.

### Scripts for Easy Switching
Create batch/shell scripts to quickly switch between configurations:

**Windows (`run_team.bat`)**:
```batch
@echo off
set BACKEND_URL=http://10.30.8.17:8000/api
flutter run
```

**macOS/Linux (`run_team.sh`)**:
```bash
#!/bin/bash
export BACKEND_URL=http://10.30.8.17:8000/api
flutter run
```

## Need Help?

1. Check the app's connection test in Settings
2. Verify your backend is running with: `python manage.py runserver 0.0.0.0:8000`
3. Test connectivity with: `curl http://YOUR_IP:8000/api/health/`
4. Ask your team lead for the correct backend URL

## Quick Reference

| Scenario | Backend URL |
|----------|-------------|
| Team Development | `http://10.30.8.17:8000/api` |
| Local Development | `http://localhost:8000/api` |
| Your Machine | `http://YOUR_IP:8000/api` |
| Team Member's Machine | `http://THEIR_IP:8000/api` |

Replace `YOUR_IP` and `THEIR_IP` with actual IP addresses.
