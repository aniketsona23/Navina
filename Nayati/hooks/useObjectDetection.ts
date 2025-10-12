import { useState, useCallback, useRef } from 'react';
import { objectDetectionAPI, handleAPIError } from '../services/api';

export interface DetectionResult {
  id: string;
  name: string;
  confidence: number;
  bounds: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  center: {
    x: number;
    y: number;
  };
}

export interface DetectionResponse {
  detections: DetectionResult[];
  num_detections: number;
  processing_time: number;
  session_id: number;
  model_info: any;
  success: boolean;
  error?: string;
}

export interface UseObjectDetectionReturn {
  detections: DetectionResult[];
  isDetecting: boolean;
  error: string | null;
  processingTime: number;
  detectObjects: (imageUri: string) => Promise<void>;
  clearDetections: () => void;
  lastDetectionTime: number | null;
}

export const useObjectDetection = (): UseObjectDetectionReturn => {
  const [detections, setDetections] = useState<DetectionResult[]>([]);
  const [isDetecting, setIsDetecting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [processingTime, setProcessingTime] = useState(0);
  const [lastDetectionTime, setLastDetectionTime] = useState<number | null>(null);
  
  // Throttle detection to avoid too many API calls
  const lastDetectionRef = useRef<number>(0);
  const DETECTION_THROTTLE_MS = 1000; // Minimum 1 second between detections

  const detectObjects = useCallback(async (imageUri: string) => {
    // Throttle detection calls
    const now = Date.now();
    if (now - lastDetectionRef.current < DETECTION_THROTTLE_MS) {
      return;
    }
    lastDetectionRef.current = now;

    setIsDetecting(true);
    setError(null);

    try {
      
      const response: DetectionResponse = await objectDetectionAPI.detectObjects(imageUri);
      
      
      if (response.success) {
        
        setDetections(response.detections);
        setProcessingTime(response.processing_time);
        setLastDetectionTime(now);
        
      } else {
        console.warn('⚠️ Step 3: Detection failed');
        throw new Error(response.error || 'Detection failed');
      }
    } catch (err) {
      console.error('❌ Step 3: Object detection error occurred');
      console.error('  - Error type:', typeof err);
      console.error('  - Error message:', err instanceof Error ? err.message : String(err));
      console.error('  - Full error:', err);
      
      const errorMessage = handleAPIError(err);
      setError(errorMessage);
      console.error('❌ Object detection failed:', errorMessage);
      
      // DISABLE FALLBACK FOR DEBUGGING - We want to see real errors
      setDetections([]);
    } finally {
      setIsDetecting(false);
    }
  }, []);

  const clearDetections = useCallback(() => {
    setDetections([]);
    setError(null);
    setProcessingTime(0);
    setLastDetectionTime(null);
  }, []);

  return {
    detections,
    isDetecting,
    error,
    processingTime,
    detectObjects,
    clearDetections,
    lastDetectionTime,
  };
};
