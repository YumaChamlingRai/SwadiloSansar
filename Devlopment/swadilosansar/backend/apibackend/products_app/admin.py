
# Register your models here.
from django.contrib import admin
from products_app.models import FoodItems

class ProductAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'price','image','category']

admin.site.register(FoodItems, ProductAdmin)