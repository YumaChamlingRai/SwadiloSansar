from django.urls import path, include
from products_app import views
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('products_app/', views.ApiOverview, name='home'),
    path('additems/products_app/', views.add_food_items, name='additems'),
    path('all/products_app/', views.view_food_items, name='view_item'),
    path('api/fooditems/<int:pk>/update/', views.update_food_item, name='update_food_item'),
    path('foodItems/<int:pk>/delete/', views.delete_food_items, name='delete-item'),
    path('foodItems/<int:pk>/', views.get_FoodItems_by_id, name='get-fooditem-by-id'),
    
    path('cart/add/', views.add_to_cart, name='add_to_cart'),
    path('cart/view/', views.view_cart, name='view_cart'),
    path('cart/update/<int:item_id>/', views.update_cart_item, name='update_cart_item'),
    path('cart/remove/<int:item_id>/', views.remove_cart_item, name='remove_cart_item'),
    
    path('give-order/', views.PlaceAnOrder, name='give_order'), 
    path('all/ordersrecord/', views.GetAllOrders, name='GetAllOrdersrRecord'),  # Get all orders for admin
    path('all/ordersrecord/user/', views.GetOrderItemsDetailsByUserID, name='GetOrderRecordsByUserID'),  # Get all orders for user
    path('all/order-items/<int:orderID>/', views.GetOrderItemsDetailsByOrderID, name='GetOrderItemsByOrderID'),  # Get order items by order id
    path('api/orders/<int:order_id>/confirm', views.confirm_order, name='confirm_order'),
    path('api/orders/<int:order_id>/cancel', views.cancel_order, name='cancel_order'),
    
    path('send_confirmation_email/', views.send_confirmation_email, name='send_confirmation_email'),
    path('verify-khalti/', views.verify_khalti_payment, name='verify-khalti'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
