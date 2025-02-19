# Generated by Django 5.0.3 on 2024-05-25 06:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('useracc', '0006_user_is_staff'),
    ]

    operations = [
        migrations.CreateModel(
            name='BlacklistedToken',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('token', models.CharField(max_length=255, unique=True)),
            ],
        ),
        migrations.AlterModelOptions(
            name='user',
            options={'verbose_name': 'Blacklisted Token', 'verbose_name_plural': 'Blacklisted Tokens'},
        ),
    ]
