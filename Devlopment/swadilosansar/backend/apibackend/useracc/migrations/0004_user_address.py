# Generated by Django 5.0.3 on 2024-04-09 08:26

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('useracc', '0003_remove_user_address'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='address',
            field=models.CharField(default='', max_length=100),
        ),
    ]
