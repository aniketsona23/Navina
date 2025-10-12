import os
import json
import time
import numpy as np
import cv2
from typing import List, Dict, Tuple
from django.conf import settings
import torch
from ultralytics import YOLO


class YOLOv5DetectionService:
    """
    YOLOv5 Object Detection Service using Ultralytics
    Provides accurate real-time object detection
    """
    
    def __init__(self, model_path: str = None, classes_path: str = None):
        """
        Initialize the YOLOv5 service
        
        Args:
            model_path: Path to the YOLOv5 model file (will download if not exists)
            classes_path: Path to the COCO classes JSON file
        """
        # Set default paths
        self.model_path = model_path or 'yolov5n.pt'  # YOLOv5 nano for speed
        self.classes_path = classes_path or os.path.join(settings.BASE_DIR, 'models', 'efficientdet_lite0', 'coco_classes.json')
        
        # Model configuration
        self.confidence_threshold = 0.5
        self.nms_threshold = 0.4
        
        # Load model and classes
        self.model = None
        self.classes = self._load_classes()
        self._load_model()
    
    def _load_classes(self) -> List[str]:
        """Load COCO class names from JSON file"""
        try:
            with open(self.classes_path, 'r') as f:
                data = json.load(f)
            
            # Extract classes from the JSON structure
            if isinstance(data, dict) and 'classes' in data:
                classes = data['classes']
            elif isinstance(data, list):
                classes = data
            else:
                raise ValueError("Invalid JSON format")
            
            print(f"✅ Loaded {len(classes)} COCO classes")
            return classes
        except Exception as e:
            print(f"❌ Error loading classes: {e}")
            # Fallback to basic classes
            return ['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat', 'traffic light']
    
    def _load_model(self):
        """Load the YOLOv5 model"""
        try:
            print("🚀 Loading YOLOv5 model...")
            
            # Load YOLOv5 model (will download if not exists)
            self.model = YOLO(self.model_path)
            
            print(f"✅ YOLOv5 model loaded successfully")
            print(f"  - Model: {self.model_path}")
            print(f"  - Device: {self.model.device}")
            print(f"  - Classes: {len(self.model.names)}")
            
            # Print available classes
            print("🔍 Available classes:")
            for i, name in self.model.names.items():
                print(f"  - {i}: {name}")
            
        except Exception as e:
            print(f"❌ Error loading YOLOv5 model: {e}")
            raise e
    
    def detect_objects(self, image: np.ndarray) -> Dict:
        """
        Detect objects in an image using YOLOv5
        
        Args:
            image: Input image as numpy array (BGR format)
            
        Returns:
            Dictionary containing detection results
        """
        start_time = time.time()
        
        try:
            print(f"🔍 YOLOv5 detection starting...")
            print(f"  - Image shape: {image.shape}")
            print(f"  - Image dtype: {image.dtype}")
            
            # Run YOLOv5 inference
            results = self.model(image, conf=self.confidence_threshold, iou=self.nms_threshold)
            
            # Process results
            detections = []
            if results and len(results) > 0:
                result = results[0]  # Get first (and only) result
                
                if result.boxes is not None and len(result.boxes) > 0:
                    boxes = result.boxes.xyxy.cpu().numpy()  # Get bounding boxes
                    confidences = result.boxes.conf.cpu().numpy()  # Get confidences
                    class_ids = result.boxes.cls.cpu().numpy().astype(int)  # Get class IDs
                    
                    print(f"🔍 YOLOv5 found {len(boxes)} detections")
                    
                    # Process each detection
                    for i, (box, confidence, class_id) in enumerate(zip(boxes, confidences, class_ids)):
                        x1, y1, x2, y2 = box
                        
                        # Get class name
                        if class_id < len(self.classes):
                            class_name = self.classes[class_id]
                        else:
                            class_name = f'class_{class_id}'
                        
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
                        print(f"  - Detection {i+1}: {class_name} ({confidence:.2f})")
                else:
                    print("🔍 No objects detected by YOLOv5")
            else:
                print("🔍 No results from YOLOv5")
            
            processing_time = time.time() - start_time
            
            return {
                'detections': detections,
                'num_detections': len(detections),
                'processing_time': processing_time,
                'model_info': {
                    'model_name': 'YOLOv5',
                    'model_path': self.model_path,
                    'device': str(self.model.device),
                    'confidence_threshold': self.confidence_threshold,
                    'nms_threshold': self.nms_threshold,
                    'classes': list(self.model.names.values())[:10] + ['...'] if len(self.model.names) > 10 else list(self.model.names.values())
                }
            }
            
        except Exception as e:
            print(f"❌ Error during YOLOv5 detection: {e}")
            import traceback
            traceback.print_exc()
            
            return {
                'detections': [],
                'num_detections': 0,
                'processing_time': time.time() - start_time,
                'error': str(e)
            }


# Global service instance
_yolov5_detection_service = None

def get_yolov5_detection_service() -> YOLOv5DetectionService:
    """Get or create the global YOLOv5 detection service instance"""
    global _yolov5_detection_service
    
    if _yolov5_detection_service is None:
        print("🚀 Initializing YOLOv5 Detection Service...")
        _yolov5_detection_service = YOLOv5DetectionService()
        print("✅ YOLOv5 Detection Service ready")
    
    return _yolov5_detection_service
