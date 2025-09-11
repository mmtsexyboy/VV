from django.urls import path
from . import views

urlpatterns = [
    # Profile URLs
    path('profile/', views.profile, name='profile'),

    # Forum URLs
    path('', views.topic_list, name='topic_list'),
    path('topic/<int:pk>/', views.topic_detail, name='topic_detail'),
    path('topic/new/', views.create_topic, name='create_topic'),
    path('topic/<int:pk>/reply/', views.create_post, name='create_post'),
    path('post/<int:pk>/edit/', views.edit_post, name='edit_post'),
    path('post/<int:pk>/delete/', views.delete_post, name='delete_post'),
]
