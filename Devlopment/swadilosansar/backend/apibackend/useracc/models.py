from django.db import models
from django.contrib.auth.models import BaseUserManager, AbstractBaseUser
from django.contrib.auth.hashers import make_password
from django.utils import timezone



class BlacklistedTokenManager(models.Manager):
    def create_token(self, token):
        return self.create(token=token)

class BlacklistedToken(models.Model):
    token = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(default=timezone.now)

    objects = BlacklistedTokenManager() 

    class Meta:
        verbose_name = 'Blacklisted Token'
        verbose_name_plural = 'Blacklisted Tokens'

    def __str__(self):
        return self.token

class UserManager(BaseUserManager):
    def create_user(self, email, phone_number, name, address, password=None, user_type='customer'):
        if not email:
            raise ValueError("Users must have an email address.")

        user = self.model(
            email=self.normalize_email(email),
            phone_number=phone_number,
            name=name,
            address=address,
            user_type=user_type,
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_staff(self, email, phone_number, name, address, password=None):
        return self.create_user(email, phone_number, name, address, password, user_type='staff')

    def create_superuser(self, email, phone_number, name, address, password=None):
        user = self.create_user(
            email=email,
            phone_number=phone_number,
            name=name,
            address=address,
            password=password,
            user_type='admin',  # Set user_type to 'admin' for superusers
        )
        user.is_admin = True
        user.is_staff = True  # Set is_staff to True for superusers
        user.save(using=self._db)
        return user

class User(AbstractBaseUser):
    USER_TYPE_CHOICES = [
        ('customer', 'Customer'),
        ('staff', 'Staff'),
        ('admin', 'Admin'),
    ]

    email = models.EmailField(
        verbose_name="email",
        max_length=255,
        unique=True,
    )
    phone_number = models.CharField(max_length=15)
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=100, default='')
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)  # Add is_staff field
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES, default='customer')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['phone_number', 'name', 'address']

    def __str__(self):
        return self.email

    def has_perm(self, perm, obj=None):
        return self.is_admin

    def has_module_perms(self, app_label):
        return True
