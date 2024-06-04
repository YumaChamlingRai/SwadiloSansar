
from rest_framework import serializers
from useracc.models import User
from xml.dom import ValidationErr
from useracc.utils import Util
from django.utils.encoding import smart_str, force_bytes,DjangoUnicodeDecodeError
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
from django.contrib.auth.tokens import PasswordResetTokenGenerator

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'phone_number', 'name', 'address', 'user_type']


class UserRegistrationSerializer(serializers.ModelSerializer):
    password_2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)
    user_type = serializers.ChoiceField(choices=User.USER_TYPE_CHOICES, default='customer')

    class Meta:
        model = User
        fields = ['id', 'email', 'phone_number', 'name', 'address', 'password', 'password_2', 'user_type']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate(self, attrs):
        password = attrs.get('password')
        password_2 = attrs.pop('password_2', None)
        if password != password_2:
            raise serializers.ValidationError("Passwords do not match.")
        return attrs

    def create(self, validated_data):
        user_type = validated_data.pop('user_type')
        print("Validated data:", validated_data)  # Add this line to print validated data
        if user_type == 'staff':
            return User.objects.create_staff(**validated_data)
        else:
            return User.objects.create_user(**validated_data)
    



class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField(max_length=255)
    password = serializers.CharField(max_length=128)
    role = serializers.ChoiceField(choices=['admin', 'staff', 'customer'])  # Add customer role

    class Meta:
        fields = ['email', 'password', 'role']
        

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'phone_number', 'name', 'address', 'user_type']


#profile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'phone_number', 'name', 'address']
        
#pasword chang
class UserPasswordSerializer(serializers.Serializer):
    password = serializers.CharField(max_length=255, style={'input_type': 'password'}, write_only=True)
    password_2 = serializers.CharField(max_length=255, style={'input_type': 'password'}, write_only=True)

    def validate(self, attrs):
        password = attrs.get('password')
        password_2 = attrs.get('password_2')

        if password != password_2:
            raise serializers.ValidationError("Passwords do not match.")

        return attrs

    def save(self, **kwargs):
        password = self.validated_data.get('password')
        user = kwargs.get('user')

        if user:
            user.set_password(password)
            user.save()

        return user

    
#change password req email
class SendPasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField(max_length=255)

    class Meta:
        fields = ['email']

    def validate(self, attrs):
        email = attrs.get('email')
        if User.objects.filter(email=email).exists():
            user = User.objects.get(email=email)
            uid = urlsafe_base64_encode(force_bytes(user.id))
            print('Encoded UID', uid)
            token = PasswordResetTokenGenerator().make_token(user)
            print('Password Reset Token', token)
            link = 'http://localhost:3000/api/user/reset/' + uid + '/' + token
            print('Password Reset Link', link)

            # Construct email data
            body = 'Click to reset password for Swadilo Sansar' +  link
            data = {
                'subject': 'Reset Your Password',
                'body': body,
                'to_email': user.email
            }

            # Send the email
            Util.send_mail(data)
            return attrs
        else:
            raise ValidationErr("Email does not exist, register first.")



#password reset serializer
class UserPasswordResetSerializer(serializers.Serializer):
    password = serializers.CharField(max_length=255,style={'input_type': 'password'},write_only=True)
    password_2 = serializers.CharField(max_length=255,style={'input_type': 'password'},write_only=True)
    class Meta:
        fields = ['password', 'password_2']
        
    def validate(self, attrs):
        try:
            password = attrs.get('password')
            password_2 = attrs.get('password_2')
            uid = self.context.get('uid')
            token = self.context.get('token')
            if password != password_2:
                raise serializers.ValidationError("Passwords do not match.")
            id = smart_str(urlsafe_base64_decode(uid))
            user = User.objects.get(id=id)
            if not PasswordResetTokenGenerator().check_token(user, token):
                raise ValidationErr('Token Is not Valid')
            user.set_password(password)
            user.save()
            return attrs
        except DjangoUnicodeDecodeError as identifier:
            PasswordResetTokenGenerator().check_token(user, token)
            raise ValidationErr('Token Is not Valid')
        
    
    
            
       