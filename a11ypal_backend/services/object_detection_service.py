import os
import json
import time
import numpy as np
import cv2
from typing import List, Dict, Tuple
from django.conf import settings

# Import YOLOv5
try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError as e:
    YOLO_AVAILABLE = False


class YOLOv5Service:
    """
    YOLOv5 Object Detection Service
    Uses YOLOv5 for accurate real-time object detection
    """
    
    def __init__(self):
        """Initialize the YOLOv5 service"""
        self.yolov5_model = None
        self._initialize_services()
    
    def _initialize_services(self):
        """Initialize YOLOv5 service"""
        
        # Initialize YOLOv5 if available
        if YOLO_AVAILABLE:
            try:
                # Try multiple paths for the model file
                import os
                model_paths = [
                    'yolov5nu.pt',  # Current directory
                    os.path.join(settings.BASE_DIR, '..', 'yolov5nu.pt'),  # Parent directory
                    os.path.join(settings.BASE_DIR, 'yolov5nu.pt'),  # Backend directory
                ]
                
                model_loaded = False
                for model_path in model_paths:
                    try:
                        self.yolov5_model = YOLO(model_path)
                        model_loaded = True
                        break
                    except Exception as path_error:
                        continue
                
                if not model_loaded:
                    self.yolov5_model = YOLO('yolov5n.pt')  # Will download if not exists
                    
            except Exception as e:
                self.yolov5_model = None
                raise Exception(f"YOLOv5 initialization failed: {e}")
        else:
            raise Exception("YOLOv5 not available - ultralytics not installed")
    
    def get_model_info(self) -> Dict:
        """Get information about the loaded model"""
        if not self.yolov5_model:
            return {
                'model_name': 'None',
                'status': 'not_loaded'
            }
        
        return {
            'model_name': 'YOLOv5',
            'model_path': 'yolov5n.pt',
            'device': str(self.yolov5_model.device),
            'confidence_threshold': 0.25,
            'nms_threshold': 0.45,
            'classes': list(self.yolov5_model.names.values())[:10] + ['...'] if len(self.yolov5_model.names) > 10 else list(self.yolov5_model.names.values())
        }
    
    def detect_objects(self, image: np.ndarray) -> Dict:
        """
        Detect objects in an image using YOLOv5 ONLY
        
        Args:
            image: Input image as numpy array (BGR format)
            
        Returns:
            Dictionary containing detection results
        """
        start_time = time.time()
        
        # Use YOLOv5 for detection
        if not self.yolov5_model:
            raise Exception("YOLOv5 model not loaded!")
        
        try:
            print(f"🔍 YOLOv5: Starting inference on image shape: {image.shape}")
            print(f"🔍 YOLOv5: Image dtype: {image.dtype}")
            print(f"🔍 YOLOv5: Image min/max: {image.min()}/{image.max()}")
            
            # Run YOLOv5 inference with lower confidence threshold
            print(f"🔍 YOLOv5: Calling model inference...")
            results = self.yolov5_model(image, conf=0.25, iou=0.45, verbose=False)
            print(f"🔍 YOLOv5: Inference completed, results type: {type(results)}")
            print(f"🔍 YOLOv5: Results length: {len(results) if results else 'None'}")
            
            detections = []
            if results and len(results) > 0:
                result = results[0]  # Get first (and only) result
                print(f"🔍 YOLOv5: Processing result, boxes: {result.boxes is not None}")
                
                if result.boxes is not None and len(result.boxes) > 0:
                    print(f"🔍 YOLOv5: Found {len(result.boxes)} detections")
                    boxes = result.boxes.xyxy.cpu().numpy()  # Get bounding boxes
                    confidences = result.boxes.conf.cpu().numpy()  # Get confidences
                    class_ids = result.boxes.cls.cpu().numpy().astype(int)  # Get class IDs
                    print(f"🔍 YOLOv5: Boxes shape: {boxes.shape}, Confidences shape: {confidences.shape}, Class IDs shape: {class_ids.shape}")
                else:
                    print(f"🔍 YOLOv5: No detections found")
            else:
                print(f"🔍 YOLOv5: No results returned")
            
            # Process each detection
            if results and len(results) > 0 and result.boxes is not None and len(result.boxes) > 0:
                for i, (box, confidence, class_id) in enumerate(zip(boxes, confidences, class_ids)):
                    x1, y1, x2, y2 = box
                    
                    # Get class name
                    class_name = self.yolov5_model.names[class_id]
                    
                    # Convert to our format
                    detection = {
                        'id': f'yolov5_{i}',
                        'class_id': int(class_id),
                        'name': class_name,
                        'confidence': float(confidence),
                        'bounds': {
                            'x': float(x1 / image.shape[1]),  # Normalized x position
                            'y': float(y1 / image.shape[0]),  # Normalized y position
                            'width': float((x2 - x1) / image.shape[1]),  # Normalized width
                            'height': float((y2 - y1) / image.shape[0]),  # Normalized height
                            'x1': int(x1),
                            'y1': int(y1),
                            'x2': int(x2),
                            'y2': int(y2)
                        },
                        'center': {
                            'x': float((x1 + x2) / 2),
                            'y': float((y1 + y2) / 2)
                        }
                    }
                    
                    detections.append(detection)            
            processing_time = time.time() - start_time
            
            return {
                'detections': detections,
                'num_detections': len(detections),
                'processing_time': processing_time,
                'model_info': {
                    'model_name': 'YOLOv5',
                    'model_path': 'yolov5n.pt',
                    'device': str(self.yolov5_model.device),
                    'confidence_threshold': 0.25,
                    'nms_threshold': 0.45,
                    'classes': list(self.yolov5_model.names.values())[:10] + ['...'] if len(self.yolov5_model.names) > 10 else list(self.yolov5_model.names.values())
                }
            }
                    
        except Exception as e:
            import traceback
            traceback.print_exc()
            
            return {
                'detections': [],
                'num_detections': 0,
                'processing_time': time.time() - start_time,
                'error': f'YOLOv5 detection failed: {str(e)}'
            }


# Global service instance
_object_detection_service = None

def get_object_detection_service() -> YOLOv5Service:
    """Get or create the global object detection service instance"""
    global _object_detection_service
    
    if _object_detection_service is None:
        _object_detection_service = YOLOv5Service()
    
    return _object_detection_service