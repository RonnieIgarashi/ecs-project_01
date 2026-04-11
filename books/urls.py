from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('save/', views.save_books, name='save_books'),
    path('health/', views.health, name='health'),
]
