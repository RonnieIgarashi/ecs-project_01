from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('infra/', views.infra, name='infra'),
    path('save/', views.save_books, name='save_books'),
    path('delete/', views.delete_books, name='delete_books'),
    path('health/', views.health, name='health'),
]
