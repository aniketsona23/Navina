from django.urls import path
from . import views

urlpatterns = [
    # Authentication
    path('register/', views.UserRegistrationView.as_view(), name='user-register'),
    path('login/', views.login_view, name='user-login'),
    path('logout/', views.logout_view, name='user-logout'),
    
    # User Profile
    path('profile/', views.UserProfileView.as_view(), name='user-profile'),
    path('profile/settings/', views.UserProfileSettingsView.as_view(), name='user-profile-settings'),
    path('dashboard/', views.user_dashboard, name='user-dashboard'),
]
