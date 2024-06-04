from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from .models import TableBooking
from .serializers import TableBookingSerializer
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def book_table(request):
    serializer = TableBookingSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def view_table_bookings(request):
    table_bookings = TableBooking.objects.all()
    serializer = TableBookingSerializer(table_bookings, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def confirm_table_booking(request, booking_id):
    try:
        booking = TableBooking.objects.get(id=booking_id)
        # Add logic to handle confirmation (e.g., change status)
        return Response({"message": "Table booking confirmed successfully."}, status=status.HTTP_200_OK)
    except TableBooking.DoesNotExist:
        return Response({"error": "Table booking not found."}, status=status.HTTP_404_NOT_FOUND)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_table_booking(request, booking_id):
    try:
        booking = TableBooking.objects.get(id=booking_id)
        booking.delete()
        return Response({"message": "Table booking deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
    except TableBooking.DoesNotExist:
        return Response({"error": "Table booking not found."}, status=status.HTTP_404_NOT_FOUND)
