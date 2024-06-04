from django.http import HttpRequest
from rest_framework.authtoken.models import Token
from useracc.models import BlacklistedToken 

import json

class TokenBlacklistMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        print("Middleware initialized")

    def __call__(self, request):
        print("Middleware called")
        if request.path == '/api/user/logout/' and request.method == 'POST':
            try:
                # Parse JSON data from the request body
                data = json.loads(request.body)
                refresh_token = data.get('refresh')

                if refresh_token:
                    # Blacklist the refresh token
                    BlacklistedToken.objects.create_token(token=refresh_token)

            except json.JSONDecodeError:
                pass  # Handle JSON decode error if necessary

        response = self.get_response(request)
        return response
