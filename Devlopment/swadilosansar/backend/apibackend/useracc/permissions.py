# permissions.py

from rest_framework.permissions import BasePermission

class IsAdminOrReadOnly(BasePermission):
    """
    Custom permission to allow only admins to delete user accounts.
    """

    def has_permission(self, request, view):
        # Allow GET, HEAD or OPTIONS requests (read-only operations)
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True

        # Check if the user is an admin
        return request.user and request.user.is_staff
