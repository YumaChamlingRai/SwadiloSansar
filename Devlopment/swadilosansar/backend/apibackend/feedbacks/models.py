from django.db import models

# Create your models here.
from django.db import models

class Feedback(models.Model):
    content = models.TextField()

    def __str__(self):
        return f"Feedback {self.pk}"
