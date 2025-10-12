from django.apps import AppConfig


class ServicesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'services'
    verbose_name = 'AI Services'
    
    def ready(self):
        """Initialize services when Django starts"""
        try:
            # Import and initialize the object detection service
            from .object_detection_service import get_object_detection_service
            service = get_object_detection_service()
        except Exception as e:
            pass
