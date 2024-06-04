from rest_framework import serializers
from useracc.models import User  # Import the User model from the useracc app
from .models import TableBooking

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name', 'phone_number']

class TableBookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # Nest the user serializer to get user details

    class Meta:
        model = TableBooking
        fields = ['id', 'branch', 'time', 'number_of_people', 'user']  # Include the 'id' field
        read_only_fields = ['user']
