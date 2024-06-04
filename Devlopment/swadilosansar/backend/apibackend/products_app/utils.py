# utils.py

from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags

def send_confirmation_email(email):
    subject = 'Order Confirmation'
    html_message = render_to_string('confirmation_email.html')  # Render the HTML template
    plain_message = strip_tags(html_message)  # Strip HTML tags to get plain text message

    sender_name = 'SwadiloSansar'
    send_mail(
        subject,
        plain_message,
        sender_name,  # Sender's name
        [email],  # List of recipient email addresses
        html_message=html_message,
    )
