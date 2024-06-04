from datetime import timezone
from django.utils import timezone

from django.db import models
from useracc.models import User

# Category choices
FOOD_CATEGORY = (
    ('momo', 'Momo'),
    ('sekuwa', 'Sekuwa'),
    ('noodles', 'Noodles'),
    ('acchar', 'Acchar'),
    ('set', 'Nepali Set'),
    ('sel', 'Sel Roti'),
    ('chatamari', 'Chatamari'),
    ('offer', 'Offers'),
)

class FoodItems(models.Model):
    image = models.ImageField(upload_to='food_images/')
    title = models.CharField(max_length=100)
    description = models.TextField()
    price = models.PositiveIntegerField()
    category = models.CharField(max_length=50, choices=FOOD_CATEGORY)

    def __str__(self):
        return self.title
    

class Cart(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    food_item = models.ForeignKey(FoodItems, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    
    def total_price(self):
        return self.quantity * self.food_item.price
    
class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(default=timezone.now)
    status = models.CharField(max_length=20, default='Pending')

    def __str__(self):
        return f"Order {self.id} by {self.user.name}"

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='order_items')
    food_item = models.ForeignKey(FoodItems, on_delete=models.CASCADE)  
    quantity = models.PositiveIntegerField(default=1)    

    def __str__(self):
        return f"Order Item: {self.food_item.title} ({self.quantity})"
