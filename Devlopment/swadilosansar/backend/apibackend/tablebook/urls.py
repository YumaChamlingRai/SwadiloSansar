from django.urls import path
from .views import book_table, view_table_bookings, confirm_table_booking, delete_table_booking

urlpatterns = [
    path('book/', book_table, name='book-table'),
    path('view/', view_table_bookings, name='view-table-bookings'),
    path('confirm/<int:booking_id>/', confirm_table_booking, name='confirm-table-booking'),
    path('delete/<int:booking_id>/', delete_table_booking, name='delete-table-booking'),
]
