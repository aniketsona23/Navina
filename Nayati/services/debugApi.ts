import axios from 'axios';

// Debug API service to test connectivity
const DEBUG_API_URL = 'http://10.30.9.162:8000/api'; // Use your computer's IP

export const debugApi = {
  /**
   * Test basic connectivity to the backend
   */
  testConnectivity: async () => {
    try {
      const response = await axios.get(`${DEBUG_API_URL}/visual-assist/test/`, {
        timeout: 10000
      });
      
      
      return {
        success: true,
        status: response.status,
        data: response.data
      };
    } catch (error: any) {
      console.error('❌ API Connectivity Test Failed:');
      console.error('Error:', error.message);
      console.error('Code:', error.code);
      console.error('Response:', error.response?.data);
      
      return {
        success: false,
        error: error.message,
        code: error.code,
        response: error.response?.data
      };
    }
  },

  /**
   * Test object detection with a simple image
   */
  testObjectDetection: async (imageUri: string) => {
    try {
      
      const formData = new FormData();
      formData.append('image', {
        uri: imageUri,
        type: 'image/jpeg',
        name: 'test_image.jpg',
      } as any);

      const response = await axios.post(`${DEBUG_API_URL}/visual-assist/detect-test/`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        timeout: 30000
      });

      
      return {
        success: true,
        data: response.data
      };
    } catch (error: any) {
      console.error('❌ Object Detection Test Failed:');
      console.error('Error:', error.message);
      console.error('Response:', error.response?.data);
      
      return {
        success: false,
        error: error.message,
        response: error.response?.data
      };
    }
  },

  /**
   * Get network information
   */
  getNetworkInfo: () => {
  }
};

export default debugApi;

