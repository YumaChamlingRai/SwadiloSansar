from django.contrib import admin
from useracc.models import User
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

class UserModelAdmin(BaseUserAdmin):
    
    list_display = ["id", "email", "phone_number", "name", "address", "user_type", "is_admin"]
    list_filter = ["is_admin", "user_type"]  
    fieldsets = [
        ("User Info", {"fields": ["email", "password"]}),
        ("Personal info", {"fields": ["phone_number", "name", "address", "user_type"]}), 
        ("Permissions", {"fields": ["is_admin"]}),
    ]
    add_fieldsets = [
        (
            None,
            {
                "classes": ["wide"],
                "fields": ["email", "phone_number", "name", "address", "user_type", "password1", "password2"],
            },
        ),
    ]
    search_fields = ["email"]
    ordering = ["email"]
    filter_horizontal = []

admin.site.register(User, UserModelAdmin)
