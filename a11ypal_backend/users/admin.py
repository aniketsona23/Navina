from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, UserProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'date_joined')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'date_joined')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('username',)
    
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email', 'phone_number', 'date_of_birth')}),
        ('Accessibility', {'fields': ('accessibility_preferences',)}),
        ('Emergency', {'fields': ('emergency_contact_name', 'emergency_contact_phone')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'visual_impairment_level', 'hearing_impairment_level', 'mobility_impairment_level')
    list_filter = ('visual_impairment_level', 'hearing_impairment_level', 'mobility_impairment_level')
    search_fields = ('user__username', 'user__email')
    raw_id_fields = ('user',)