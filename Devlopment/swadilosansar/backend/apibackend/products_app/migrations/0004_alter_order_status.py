# Generated by Django 5.0.3 on 2024-04-21 05:36

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('products_app', '0003_alter_fooditems_category_alter_fooditems_title_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='status',
            field=models.CharField(default='Food No Delivered', max_length=100),
        ),
    ]
