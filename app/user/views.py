"""
Views for the user API.
"""
from rest_framework import generics

from user.serializers import UserSerializer


# CreateAPIView handles http post requests
# designed for creating objects in the database
class CreateUserView(generics.CreateAPIView):
    """Create a new user in the system."""
    serializer_class = UserSerializer

