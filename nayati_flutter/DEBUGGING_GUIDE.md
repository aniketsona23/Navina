# Object Detection Debugging Guide

## 🔍 **Debugging Steps for Object Detection Issues**

I've added comprehensive debugging features to help identify why object detection isn't working. Follow these steps:

### **1. Test API Connection First**
- Open the Visual Assist screen
- Tap the **green WiFi button** (Test API)
- Check the console logs and snackbar message
- This will tell us if the backend is reachable

### **2. Test Object Detection**
- Tap the **orange bug button** (Test Detection)
- This will capture an image and send it to the backend
- Check the console logs for detailed information

### **3. Check Console Logs**
Look for these specific log messages:

```
🧪 Testing API connection...
📤 Sending image to backend: /path/to/image.jpg
📥 Backend response status: 200
📥 Backend response data: {...}
🔍 Starting object detection for: /path/to/image.jpg
📊 Detection result: {...}
🎯 Found X detections
✅ Detections processed: X
```

### **4. Common Issues and Solutions**

#### **Issue 1: API Connection Failed**
```
❌ API Connection: Failed - Connection refused
```
**Solution**: Check if Django backend is running on `http://10.30.8.17:8000`

#### **Issue 2: Backend Returns Empty Detections**
```
📥 Backend response data: {"detections": [], "num_detections": 0}
```
**Solution**: The backend is working but not detecting objects. Check:
- Image quality (too dark, blurry, etc.)
- Object detection model is loaded
- Backend logs for errors

#### **Issue 3: Backend Returns Error**
```
📥 Backend response data: {"error": "Model not loaded"}
```
**Solution**: Backend issue - check Django logs

#### **Issue 4: No Response from Backend**
```
📥 Backend response status: 500
```
**Solution**: Backend server error - check Django logs

### **5. Manual Testing Steps**

1. **Start the app** and go to Visual Assist screen
2. **Wait for camera** to initialize (you'll see the camera feed)
3. **Tap the green WiFi button** to test API connection
4. **Tap the orange bug button** to test object detection
5. **Check the console logs** for detailed information
6. **Try pointing the camera** at different objects (people, cars, etc.)

### **6. Expected Console Output**

**Successful Detection:**
```
🧪 Testing API connection...
📤 Sending image to backend: /data/user/0/com.example.nayati_flutter/app_flutter/recording_1234567890.jpg
📥 Backend response status: 200
📥 Backend response data: {
  "detections": [
    {
      "id": "1",
      "name": "person",
      "confidence": 0.85,
      "bounds": {"x": 0.1, "y": 0.2, "width": 0.3, "height": 0.4},
      "center": {"x": 0.25, "y": 0.4}
    }
  ],
  "num_detections": 1,
  "processing_time": 0.5
}
🔍 Starting object detection for: /data/user/0/com.example.nayati_flutter/app_flutter/recording_1234567890.jpg
📊 Detection result: {success: true, detections: [...], num_detections: 1}
🎯 Found 1 detections
✅ Detections processed: 1
```

**Failed Detection:**
```
🧪 Testing API connection...
📤 Sending image to backend: /data/user/0/com.example.nayati_flutter/app_flutter/recording_1234567890.jpg
📥 Backend response status: 200
📥 Backend response data: {"detections": [], "num_detections": 0}
🔍 Starting object detection for: /data/user/0/com.example.nayati_flutter/app_flutter/recording_1234567890.jpg
📊 Detection result: {success: true, detections: [], num_detections: 0}
🎯 Found 0 detections
✅ Detections processed: 0
```

### **7. Troubleshooting Commands**

**Check if backend is running:**
```bash
curl http://10.30.8.17:8000/api/health/
```

**Check Django logs:**
```bash
cd a11ypal_backend
python manage.py runserver 0.0.0.0:8000
```

### **8. What to Look For**

1. **API Connection**: Should return success
2. **Image Upload**: Should show file path and size
3. **Backend Response**: Should return 200 status
4. **Detection Data**: Should contain detections array
5. **Processing**: Should show detection results

### **9. Next Steps Based on Results**

- **If API fails**: Check backend server and network
- **If API succeeds but no detections**: Check image quality and backend model
- **If detections work**: The issue was in the UI display
- **If still failing**: Check Django backend logs for specific errors

## 🎯 **Quick Test Checklist**

- [ ] Camera initializes properly
- [ ] API connection test passes
- [ ] Object detection test runs without errors
- [ ] Console shows detailed logs
- [ ] Backend returns response (even if empty)
- [ ] No crashes or exceptions

Run through this checklist and let me know what you find in the console logs!
