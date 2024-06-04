from django.urls import path, include
from useracc.views import RegistrationSuccessView, UserDeleteView, UserListView,UserRegistrationView,UserLoginView,UserProfileView,UserChangePasswordView,SendPasswordResetView,UserPasswordResetView, logout_view
from useracc import views  # Import your views module

urlpatterns = [
    path('register/', UserRegistrationView.as_view(),name='register'),
    path('registration-success/', RegistrationSuccessView.as_view(), name='registration_success'),
    path('login/', UserLoginView.as_view(),name='login'),
    path('profile/', UserProfileView.as_view(),name='profile'),
    path('api/users/', UserListView.as_view(), name='user-list'),
    path('api/users/<int:pk>/', UserDeleteView.as_view(), name='user-delete'),  
    path('changepw/', UserChangePasswordView.as_view(),name='changepw'),
    path('send-reset-email/', SendPasswordResetView.as_view(),name='send-reset-email'),
    path('reset-pw/<uid>/<token>/', UserPasswordResetView.as_view(),name='reset-pw'),
    path('logout/', logout_view, name='logout'),
   
]

