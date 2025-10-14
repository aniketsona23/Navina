import axios from 'axios';

// API Configuration
// For mobile devices, use your computer's IP address instead of localhost
// Find your IP with: ipconfig (Windows) or ifconfig (Mac/Linux)
const API_BASE_URL = 'http://10.30.11.234:8000/api'; // Django backend running on your computer's IP
const API_TIMEOUT = 30000; // 30 seconds

// Create axios instance
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = getAuthToken();
    if (token) {
      config.headers.Authorization = `Token ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// Auth token management (you can implement this based on your auth system)
const getAuthToken = (): string | null => {
  // TODO: Implement token storage/retrieval
  // For now, return null (you might want to use AsyncStorage or SecureStore)
  return null;
};

// Object Detection API
export const objectDetectionAPI = {
  /**
   * Detect objects in an image using EfficientDet-Lite0
   * @param imageUri - URI of the image to analyze
   * @returns Promise with detection results
   */
  detectObjects: async (imageUri: string) => {
    try {
      
      // Create FormData for file upload
      const formData = new FormData();
      
      // Add image file to FormData
      formData.append('image', {
        uri: imageUri,
        type: 'image/jpeg',
        name: 'camera_image.jpg',
      } as any);

      
      // Use test endpoint (no authentication required)
      const response = await apiClient.post('/visual-assist/detect-test/', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });


      return response.data;
    } catch (error) {
      console.error('❌ API CALL FAILED - detectObjects');
      console.error('  - Error type:', typeof error);
      console.error('  - Error message:', error instanceof Error ? error.message : String(error));
      
      if (error && typeof error === 'object' && 'response' in error) {
        const axiosError = error as any;
        console.error('  - Response status:', axiosError.response?.status);
        console.error('  - Response data:', axiosError.response?.data);
        console.error('  - Response headers:', axiosError.response?.headers);
      }
      
      console.error('  - Full error object:', error);
      throw error;
    }
  },

  /**
   * Get object detection history
   * @returns Promise with detection history
   */
  getDetectionHistory: async () => {
    try {
      const response = await apiClient.get('/visual-assist/object-detection/');
      return response.data;
    } catch (error) {
      console.error('Failed to fetch detection history:', error);
      throw error;
    }
  },

  /**
   * Get visual assist statistics
   * @returns Promise with usage statistics
   */
  getStats: async () => {
    try {
      const response = await apiClient.get('/visual-assist/stats/');
      return response.data;
    } catch (error) {
      console.error('Failed to fetch stats:', error);
      throw error;
    }
  },
};

// Image Processing API
export const imageProcessingAPI = {
  /**
   * Analyze image for various features
   * @param imageUri - URI of the image to analyze
   * @param analysisType - Type of analysis to perform
   * @returns Promise with analysis results
   */
  analyzeImage: async (imageUri: string, analysisType: string = 'object_detection') => {
    try {
      const formData = new FormData();
      formData.append('image', {
        uri: imageUri,
        type: 'image/jpeg',
        name: 'analysis_image.jpg',
      } as any);
      formData.append('analysis_type', analysisType);

      const response = await apiClient.post('/visual-assist/analyze/', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      return response.data;
    } catch (error) {
      console.error('Image analysis failed:', error);
      throw error;
    }
  },

  /**
   * Extract text from image using OCR
   * @param imageUri - URI of the image to analyze
   * @returns Promise with extracted text
   */
  extractText: async (imageUri: string) => {
    try {
      const formData = new FormData();
      formData.append('image', {
        uri: imageUri,
        type: 'image/jpeg',
        name: 'ocr_image.jpg',
      } as any);

      const response = await apiClient.post('/visual-assist/extract-text/', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      return response.data;
    } catch (error) {
      console.error('Text extraction failed:', error);
      throw error;
    }
  },
};

// User API
export const userAPI = {
  /**
   * Login user
   * @param username - Username
   * @param password - Password
   * @returns Promise with auth token
   */
  login: async (username: string, password: string) => {
    try {
      const response = await apiClient.post('/users/login/', {
        username,
        password,
      });
      return response.data;
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  },

  /**
   * Register new user
   * @param userData - User registration data
   * @returns Promise with user data
   */
  register: async (userData: any) => {
    try {
      const response = await apiClient.post('/users/register/', userData);
      return response.data;
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    }
  },
};

// Error handling utilities
export const handleAPIError = (error: any): string => {
  if (error.response?.data?.error) {
    return error.response.data.error;
  } else if (error.response?.data?.detail) {
    return error.response.data.detail;
  } else if (error.message) {
    return error.message;
  } else {
    return 'An unexpected error occurred';
  }
};

// Network status utilities
export const isNetworkAvailable = async (): Promise<boolean> => {
  try {
    const response = await apiClient.get('/users/profile/');
    return response.status === 200;
  } catch (error) {
    return false;
  }
};

export default apiClient;
