from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from .forms import ProfileForm
from .models import Profile, Topic, Post

# Profile Views
@login_required
def profile(request):
    # The post_save signal in models.py ensures a profile exists.
    profile = request.user.profile

    if request.method == 'POST':
        form = ProfileForm(request.POST, request.FILES, instance=profile)
        if form.is_valid():
            form.save()
            return redirect('profile')
    else:
        form = ProfileForm(instance=profile)

    return render(request, 'account/profile.html', {'form': form})

# Forum Views
def topic_list(request):
    topics = Topic.objects.all().order_by('-created_at')
    return render(request, 'forum/topic_list.html', {'topics': topics})

from .forms import PostForm

def topic_detail(request, pk):
    topic = get_object_or_404(Topic, pk=pk)
    form = PostForm()
    return render(request, 'forum/topic_detail.html', {'topic': topic, 'form': form})

from .forms import TopicForm, PostForm

@login_required
def create_topic(request):
    if request.method == 'POST':
        form = TopicForm(request.POST)
        if form.is_valid():
            topic = form.save(commit=False)
            topic.author = request.user
            topic.save()
            Post.objects.create(topic=topic, content=form.cleaned_data['content'], author=request.user)
            return redirect('topic_detail', pk=topic.pk)
    else:
        form = TopicForm()
    return render(request, 'forum/create_topic.html', {'form': form})

@login_required
def create_post(request, pk):
    topic = get_object_or_404(Topic, pk=pk)
    if request.method == 'POST':
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.topic = topic
            post.author = request.user
            post.save()
            return redirect('topic_detail', pk=topic.pk)
    # This view should not be accessed via GET, but redirecting is safe.
    return redirect('topic_detail', pk=topic.pk)

@login_required
def edit_post(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.user != post.author:
        return redirect('topic_detail', pk=post.topic.pk)

    if request.method == 'POST':
        form = PostForm(request.POST, instance=post)
        if form.is_valid():
            form.save()
            return redirect('topic_detail', pk=post.topic.pk)
    else:
        form = PostForm(instance=post)

    return render(request, 'forum/edit_post.html', {'form': form, 'post': post})

@login_required
def delete_post(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.user != post.author:
        return redirect('topic_detail', pk=post.topic.pk)

    topic_pk = post.topic.pk
    post.delete()
    return redirect('topic_detail', pk=topic_pk)
