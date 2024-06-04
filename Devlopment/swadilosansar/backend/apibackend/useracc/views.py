from django.shortcuts import render
from django.views.generic import ListView
from useracc.models import User
from useracc.models import BlacklistedToken
from django.shortcuts import get_object_or_404
from .permissions import IsAdminOrReadOnly
from django.http import JsonResponse
from useracc.serializers import UserSerializer
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from useracc.serializers import  UserRegistrationSerializer, UserLoginSerializer,UserProfileSerializer,UserPasswordSerializer,SendPasswordResetSerializer,UserPasswordResetSerializer
from django.contrib.auth import authenticate
from useracc.renderers import UserRenderer
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from django.core.mail import send_mail
from django.http import HttpResponse
from django.shortcuts import render, redirect
from .forms import RegistrationForm    
from django.views.generic.base import View
from django.views import View
from rest_framework.permissions import IsAdminUser
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken




#token generation
def get_tokens_for_user(user):
  refresh = RefreshToken.for_user(user)
  return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
   }

#registation
class UserRegistrationView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            print("Serializer data:", serializer.validated_data)  # Add this line to print validated data
            validated_data = serializer.validated_data
            user_type = validated_data.pop('user_type')
            if user_type == 'staff':
                user = User.objects.create_staff(**validated_data)
                user.is_staff = True  # Set is_staff to True for staff users
                user.save()  # Call save() on the user instance
            else:  # Customer
                User.objects.create_user(**validated_data)
            return JsonResponse({'message': 'Registration successful'}, status=status.HTTP_200_OK)
        else:
            print("Serializer errors:", serializer.errors)  # Add this line to print serializer errors
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RegistrationSuccessView(View):
    def get(self, request):
        return HttpResponse("Registration Successful")
    
#Login
from rest_framework.authtoken.models import Token

from rest_framework_simplejwt.authentication import JWTAuthentication

from rest_framework.authtoken.models import Token
from rest_framework_simplejwt.tokens import RefreshToken

class UserLoginView(APIView):
    def post(self, request, format=None):
        email = request.data.get('email')
        password = request.data.get('password')
        role = request.data.get('role')
        
        if role not in ['admin', 'staff', 'customer']:
            return Response({'errors': {'role': ['Invalid role']}}, status=status.HTTP_400_BAD_REQUEST)
        
        user = authenticate(request, email=email, password=password)
        if user is not None:
            if role == 'admin' and user.is_admin:
                # Redirect to admin.html or send token for web login
                refresh = RefreshToken.for_user(user)
                access = refresh.access_token
                return Response({'refresh': str(refresh), 'access': str(access), 'role': 'admin'}, status=status.HTTP_200_OK)
            elif role == 'staff' and user.is_staff:
                # Redirect to staff.html or send token for web login
                refresh = RefreshToken.for_user(user)
                access = refresh.access_token
                return Response({'refresh': str(refresh), 'access': str(access), 'role': 'staff'}, status=status.HTTP_200_OK)
            elif role == 'customer':
                # Generate both refresh and access tokens for the customer
                refresh = RefreshToken.for_user(user)
                access = refresh.access_token
                token, _ = Token.objects.get_or_create(user=user)
                return Response({'refresh': str(refresh), 'access': str(access), 'token': token.key, 'role': 'customer'}, status=status.HTTP_200_OK)
            else:
                return Response({'errors': {'role': ['Unauthorized role']}}, status=status.HTTP_403_FORBIDDEN)
        else:
            return Response({'errors': {'non_field_error': ['Invalid Credentials']}}, status=status.HTTP_400_BAD_REQUEST)



class UserProfileView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]
    def get(self, request, format=None):
      user = request.user
      serializer = UserProfileSerializer(user)
      return Response(serializer.data, status=status.HTTP_200_OK)
  
#Password change
class UserChangePasswordView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]   
   
    def post(self, request, format=None):
        serializer = UserPasswordSerializer(data=request.data, context={'user': request.user})
        if serializer.is_valid(raise_exception=True):
            serializer.save(user=request.user)
            return Response({'msg': 'Password Changed'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


#password reset in email  
class SendPasswordResetView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = SendPasswordResetSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            return Response({'msg':'Check your email to reset password'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
#user pw reset
class UserPasswordResetView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request,  uid, token, format=None):
        serializer = UserPasswordResetSerializer(data=request.data,context={'uid': uid,'token': token})
        if serializer.is_valid(raise_exception=True):
            return Response({'msg':'Password Reset Sucessful'},status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
from rest_framework.decorators import api_view # type: ignore




class UserListView(View):
    def get(self, request, *args, **kwargs):
        users = User.objects.all()
        data = [{'id':user.id,'email': user.email, 'phone_number': user.phone_number, 'name': user.name, 'address': user.address, 'user_type': user.user_type} for user in users]
        return JsonResponse(data, safe=False)
    
from django.shortcuts import get_object_or_404

class UserDeleteView(APIView):
    def delete(self, request, pk):
        # Use get_object_or_404 to simplify the code
        user = get_object_or_404(User, pk=pk)
        user.delete()
        return JsonResponse({'message': 'User deleted successfully'}, status=204)

    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    try:
        # Invalidate the DRF token
        if hasattr(request.user, 'auth_token'):
            request.user.auth_token.delete()
        
        return Response({"detail": "Successfully logged out."}, status=status.HTTP_200_OK)
    except Exception as e:
        print(f"Error during logout: {str(e)}")
        return Response({"detail": "Error during logout."}, status=status.HTTP_400_BAD_REQUEST)