import apiClient from './api';

export const testBackendConnection = async (): Promise<{
  isConnected: boolean;
  error?: string;
  responseTime?: number;
}> => {
  const startTime = Date.now();
  
  try {
    console.log('Testing backend connection...');
    
    // Try to reach the backend
    const response = await apiClient.get('/health/', {
      timeout: 5000, // 5 second timeout for quick test
    });
    
    const responseTime = Date.now() - startTime;
    
    console.log('Backend connection successful:', {
      status: response.status,
      responseTime: `${responseTime}ms`
    });
    
    return {
      isConnected: true,
      responseTime
    };
  } catch (error: any) {
    const responseTime = Date.now() - startTime;
    
    console.error('Backend connection failed:', {
      error: error.message,
      code: error.code,
      responseTime: `${responseTime}ms`
    });
    
    return {
      isConnected: false,
      error: error.message || 'Connection failed',
      responseTime
    };
  }
};

export const getBackendInfo = () => {
  return {
    baseURL: 'http://10.30.8.17:8000/api',
    timeout: 30000,
    expectedEndpoints: [
      '/health/',
      '/hearing-assist/transcribe/',
      '/hearing-assist/speech-to-text/',
      '/visual-assist/detect-test/'
    ]
  };
};
