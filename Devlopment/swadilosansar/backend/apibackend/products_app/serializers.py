from rest_framework import serializers # type: ignore
from products_app.models import FoodItems, Order, OrderItem, Cart, CartItem
from useracc.serializers import UserSerializer

class FoodItemsSerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodItems
        fields = '__all__'

    def validate(self, data):
        image = data.get("image")
        title = data.get("title")
        category = data.get("category")
        price = data.get("price")

        if price is not None and price < 0:
            raise serializers.ValidationError("Invalid Price")

        if not title or not category or price is None or not image:
            raise serializers.ValidationError("Image, Title, Category, and Price are required for the food item.")

        return data

class OrderFoodSerializer(serializers.ModelSerializer):
    food_item = serializers.StringRelatedField()  # Display the title of the food item
    food_item_id = serializers.PrimaryKeyRelatedField(
        queryset=FoodItems.objects.all(), source='food_item', write_only=True)

    class Meta:
        model = OrderItem
        fields = ['food_item', 'food_item_id', 'quantity']

class OrderSerializer(serializers.ModelSerializer):
    order_items = OrderFoodSerializer(many=True)

    class Meta:
        model = Order
        fields = ['id', 'user', 'total_amount', 'paid_amount', 'order_items']

    def create(self, validated_data):
        order_items_data = validated_data.pop('order_items')
        order = Order.objects.create(**validated_data)
        for order_item_data in order_items_data:
            OrderItem.objects.create(order=order, **order_item_data)
        return order

class GetOrderedItemDetailsSerializer(serializers.ModelSerializer):
    food_item = FoodItemsSerializer()

    class Meta:
        model = OrderItem
        fields = ['food_item', 'quantity']

class GetAllOrderedDetailSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    order_items = GetOrderedItemDetailsSerializer(many=True)

    class Meta:
        model = Order
        fields = ['id', 'user', 'total_amount', 'paid_amount', 'order_items', 'status', 'created_at']

    def get_user(self, obj):
        return {
            'name': obj.user.name,
            'email': obj.user.email,
            'phone_number': obj.user.phone_number  # Assuming phone number is a field in your User model
        }

class CartItemSerializer(serializers.ModelSerializer):
    food_item = FoodItemsSerializer(read_only=True)

    class Meta:
        model = CartItem
        fields = ['id', 'food_item', 'quantity']

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)

    class Meta:
        model = Cart
        fields = ['id', 'user', 'items', 'created_at', 'updated_at']
