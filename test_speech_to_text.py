#!/usr/bin/env python3
"""
Test script for speech-to-text functionality
Run this script to test the Django backend speech-to-text endpoint
"""

import os
import sys
import django
import requests
import json

# Add the backend directory to Python path
sys.path.append('a11ypal_backend')

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'a11ypal_backend.settings')
django.setup()

def test_speech_to_text_endpoint():
    """Test the speech-to-text endpoint"""
    
    # Backend URL (adjust if needed)
    base_url = "http://localhost:8000"
    transcribe_url = f"{base_url}/api/hearing-assist/transcribe/"
    
    print("Testing Speech-to-Text Endpoint")
    print("=" * 50)
    
    # Check if backend is running
    try:
        response = requests.get(f"{base_url}/api/", timeout=5)
        print(f"✓ Backend is running at {base_url}")
    except requests.exceptions.RequestException:
        print(f"✗ Backend is not running at {base_url}")
        print("Please start the Django backend first:")
        print("cd a11ypal_backend && python manage.py runserver")
        return False
    
    # Test with a sample audio file (you would need to provide a real audio file)
    print("\nTesting transcription endpoint...")
    print("Note: This test requires a valid audio file and user authentication")
    
    # You would need to:
    # 1. Create a test user and get authentication token
    # 2. Provide a real audio file for testing
    # 3. Send the request with proper authentication
    
    print("\nTo test with real audio:")
    print("1. Start the Django backend: python manage.py runserver")
    print("2. Create a user and get authentication token")
    print("3. Use the React Native app to record audio and test transcription")
    
    return True

def test_dependencies():
    """Test if all required dependencies are installed"""
    print("\nTesting Dependencies")
    print("=" * 50)
    
    required_packages = [
        'speech_recognition',
        'librosa',
        'soundfile',
        'pydub',
        'numpy',
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✓ {package}")
        except ImportError:
            print(f"✗ {package} - MISSING")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\nMissing packages: {', '.join(missing_packages)}")
        print("Install them with: pip install -r requirements.txt")
        return False
    
    print("\n✓ All required packages are installed")
    return True

def main():
    """Main test function"""
    print("Speech-to-Text Implementation Test")
    print("=" * 50)
    
    # Test dependencies
    deps_ok = test_dependencies()
    
    if not deps_ok:
        print("\nPlease install missing dependencies first.")
        return
    
    # Test backend endpoint
    endpoint_ok = test_speech_to_text_endpoint()
    
    if endpoint_ok:
        print("\n✓ Speech-to-text implementation is ready for testing")
        print("\nNext steps:")
        print("1. Start the Django backend: cd a11ypal_backend && python manage.py runserver")
        print("2. Start the React Native app: cd Nayati && npm start")
        print("3. Test audio recording and transcription in the Hearing Assist screen")
    else:
        print("\n✗ Backend setup incomplete")

if __name__ == "__main__":
    main()
