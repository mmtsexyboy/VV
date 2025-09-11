from django import forms
from .models import Profile, Topic, Post

class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['signature', 'profile_pic']
        widgets = {
            'signature': forms.Textarea(attrs={'rows': 3}),
        }

class TopicForm(forms.ModelForm):
    content = forms.CharField(widget=forms.Textarea(attrs={'rows': 10}), label="First Post")

    class Meta:
        model = Topic
        fields = ['title']

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['content']
        widgets = {
            'content': forms.Textarea(attrs={'rows': 5, 'style': 'width: 100%;'}),
        }
        labels = {
            'content': '' # No label for the reply box
        }
