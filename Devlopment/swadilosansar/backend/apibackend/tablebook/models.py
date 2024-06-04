from django.db import models
from useracc.models import User  # Import the User model
from django.conf import settings


class TableBooking(models.Model):
    BRANCH_CHOICES = (
        ('Branch A', 'Branch A'),
        ('Branch B', 'Branch B'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Use the imported User model
    branch = models.CharField(max_length=20, choices=BRANCH_CHOICES)
    time = models.CharField(max_length=20)  # Assuming user inputs time manually
    number_of_people = models.PositiveIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Table booking for {self.number_of_people} people at {self.branch} on {self.time}'

        