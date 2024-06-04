from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_feedback, name='create_feedback'),
    path('list/', views.list_feedbacks, name='list_feedbacks'), 
]
