from django.shortcuts import render
from apibackend import settings
from rest_framework.response import Response
from rest_framework import serializers, status
from .models import FoodItems
from .models import Order, OrderItem
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view
from django.http import JsonResponse
from rest_framework.renderers import JSONRenderer 
from rest_framework.status import HTTP_200_OK
from .models import FOOD_CATEGORY
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.shortcuts import get_object_or_404
from .utils import send_confirmation_email

#importing serializers from FoodItems_app
from products_app.serializers import FoodItemsSerializer,OrderFoodSerializer,GetOrderedItemDetailsSerializer,GetAllOrderedDetailSerializer, OrderSerializer

# Create your views here.
@api_view(['GET'])
def ApiOverview(request):
    api_urls = {
        'all_items': '/',
        'Search by Category': '/?category=category_name',
        'Add': '/additems',
        'Update': '/update/pk',
        'Delete': '/item/pk/delete',
    }
 
    return Response(api_urls)

@api_view(['POST'])
def add_food_items(request):
    serializer = FoodItemsSerializer(data=request.data)
     
    if serializer.is_valid():
        serializer.save()
        return Response({
            "message": "FoodItem added successfully",
            "data": serializer.data
        }, status=status.HTTP_201_CREATED)  # Changed status to 201 Created
    else:
        return Response({
            "message": "Validation error",
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)  # Kept status as 400 Bad Request@api_view(['GET'])

        
@api_view(['GET'])
def view_food_items(request):
    category = request.GET.get('category')

    if category and category != 'all':
        items = FoodItems.objects.filter(category=category)
    else:
        items = FoodItems.objects.all()

    serializer = FoodItemsSerializer(items, many=True, context={'request': request})
    return Response(serializer.data)


@api_view(['PUT'])
def update_food_item(request, pk):
    item = get_object_or_404(FoodItems, pk=pk)
    serializer = FoodItemsSerializer(instance=item, data=request.data, partial=True)  # `partial=True` allows partial updates

    if serializer.is_valid():
        serializer.save()
        return Response({
            "message": "Food item updated successfully",
            "data": serializer.data
        }, status=status.HTTP_200_OK)
    return Response({
        "message": "Validation error",
        "errors": serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)
    
    
@api_view(['DELETE'])
def delete_food_items(request, pk):
    item = get_object_or_404(FoodItems, pk=pk)
    item.delete()
    return Response({"message": "Item deleted successfully."}, status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def get_FoodItems_by_id(request, pk):
    item = get_object_or_404(FoodItems, pk=pk)

    if item:
        serializer = FoodItemsSerializer(item)
        return Response(serializer.data)
    else:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    
from .models import Cart, CartItem, FoodItems
from .serializers import CartSerializer, CartItemSerializer
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_to_cart(request):
    user = request.user
    food_item_id = request.data.get('food_item_id')
    quantity = request.data.get('quantity', 1)
    
    cart, created = Cart.objects.get_or_create(user=user)
    
    food_item = get_object_or_404(FoodItems, id=food_item_id)
    cart_item, created = CartItem.objects.get_or_create(cart=cart, food_item=food_item)
    
    if not created:
        cart_item.quantity += int(quantity)
    else:
        cart_item.quantity = int(quantity)
    
    cart_item.save()
    
    return Response({'message': 'Item added to cart successfully.'}, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def view_cart(request):
    user = request.user
    cart = get_object_or_404(Cart, user=user)
    serializer = CartSerializer(cart)
    return Response(serializer.data)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_cart_item(request, item_id):
    user = request.user
    cart_item = get_object_or_404(CartItem, id=item_id, cart__user=user)
    
    quantity = request.data.get('quantity')
    if quantity is not None:
        cart_item.quantity = int(quantity)
        cart_item.save()
        return Response({'message': 'Cart item updated successfully.'}, status=status.HTTP_200_OK)
    
    return Response({'error': 'Invalid data.'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_cart_item(request, item_id):
    user = request.user
    cart_item = get_object_or_404(CartItem, id=item_id, cart__user=user)
    cart_item.delete()
    return Response({'message': 'Cart item removed successfully.'}, status=status.HTTP_204_NO_CONTENT)

from django.shortcuts import redirect

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def PlaceAnOrder(request):
    user = request.user
    cart = get_object_or_404(Cart, user=user)
    if not cart.items.exists():
        return Response({"message": "Cart is empty."}, status=status.HTTP_400_BAD_REQUEST)

    payment_method = request.data.get('payment_method')
    if payment_method not in ['Khalti', 'Cash on Delivery']:
        return Response({"message": "Invalid payment method."}, status=status.HTTP_400_BAD_REQUEST)

    order_data = {
        "user": user.id,
        "total_amount": sum(item.food_item.price * item.quantity for item in cart.items.all()),
        "paid_amount": request.data.get('paid_amount', 0),
        "order_items": [
            {"food_item_id": item.food_item.id, "quantity": item.quantity}
            for item in cart.items.all()
        ]
    }

    serializer = OrderSerializer(data=order_data)
    if serializer.is_valid():
        order = serializer.save()
        cart.items.all().delete()  # Clear the cart after placing the order
        response_data = {
            "message": "Order placed successfully.",
            "order": serializer.data
        }
        return Response(response_data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def GetAllOrders(request):
    orders = Order.objects.all()
    serializer = GetAllOrderedDetailSerializer(orders, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def confirm_order(request, order_id):
    try:
        order = get_object_or_404(Order, id=order_id)
        order.status = 'Confirmed'
        order.save()

        # Send confirmation email to the user
        send_confirmation_email(order.user.email)
        return Response({"message": "Order confirmed successfully and confirmation email sent."}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# Function to send confirmation email
def send_confirmation_email_view(request):
    # Fetch orders that need confirmation
    orders = Order.objects.filter(status='Pending')  # Assuming 'Pending' is the status of orders that need confirmation

    # Iterate over orders and send confirmation email to each customer
    for order in orders:
        user_email = order.user.email
        send_confirmation_email(user_email)  # Assuming send_confirmation_email function accepts user_email as parameter

    return JsonResponse({'message': 'Confirmation emails sent successfully.'})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cancel_order(request, order_id):
    order = get_object_or_404(Order, id=order_id)
    order.delete()
    return Response({"message": "Order cancelled successfully."}, status=status.HTTP_200_OK)


@api_view(['GET'])
def GetOrderItemsDetailsByOrderID(request, orderID):
    try:
        order_items = OrderItem.objects.filter(order_id=orderID)
        serializer = GetOrderedItemDetailsSerializer(order_items, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except OrderItem.DoesNotExist:
        return Response({"message": "Ordered Food items not found"}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def GetOrderItemsDetailsByUserID(request):
    try:
        user_id = request.user.id
        orders = Order.objects.filter(user_id=user_id)
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Order.DoesNotExist:
        return Response({"message": "Orders not found for the current user details"}, status=status.HTTP_404_NOT_FOUND)
    
    
@api_view(['POST'])
def checkout(request):
    serializer = OrderSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


def get_categories(request):
    categories = [category[1] for category in FOOD_CATEGORY]
    return JsonResponse(categories, safe=False)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_khalti_payment(request):
    user = request.user
    payment_token = request.data.get('token')
    amount = request.data.get('amount')

    # Replace with actual verification URL and headers required by Khalti
    khalti_verify_url = "https://khalti.com/api/v2/payment/verify/"
    headers = {
        "Authorization": "Key test_secret_key_dc74fd7b11f14ec6a9785e80c96b7375"  # Replace with your actual secret key
    }
    payload = {
        "token": payment_token,
        "amount": amount
    }

    response = request.post(khalti_verify_url, headers=headers, data=payload)
    if response.status_code == 200:
        # Payment verified successfully, place the order
        cart = get_object_or_404(Cart, user=user)
        order_data = {
            "user": user.id,
            "total_amount": sum(item.food_item.price * item.quantity for item in cart.items.all()),
            "paid_amount": amount / 100,  # Khalti amount is in paisa
            "order_items": [
                {"food_item": item.food_item.id, "quantity": item.quantity}
                for item in cart.items.all()
            ]
        }

        serializer = OrderSerializer(data=order_data)
        if serializer.is_valid():
            order = serializer.save()
            cart.items.all().delete()  # Clear the cart after placing the order
            response_data = {
                "message": "Order placed successfully.",
                "order": serializer.data
            }
            return Response(response_data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    else:
        return Response({"message": "Failed to verify payment."}, status=status.HTTP_400_BAD_REQUEST)
