from django import forms # type: ignore
from .models import User

class RegistrationForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ['email', 'phone_number', 'name', 'address', 'password', 'user_type']
        widgets = {
            'password': forms.PasswordInput(),
        }