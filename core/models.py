from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from PIL import Image
from io import BytesIO
from django.core.files.base import ContentFile

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    signature = models.TextField(max_length=500, blank=True)
    profile_pic = models.ImageField(upload_to='profile_pics', blank=True, null=True)

    def __str__(self):
        return f'{self.user.username} Profile'

    def save(self, *args, **kwargs):
        # Check if the profile picture has been updated
        if self.pk:
            try:
                old_profile = Profile.objects.get(pk=self.pk)
                if old_profile.profile_pic == self.profile_pic:
                    # If the picture is the same, just save the other fields
                    super().save(*args, **kwargs)
                    return
            except Profile.DoesNotExist:
                pass  # This is a new profile, so process the image

        if self.profile_pic:
            # Open the image
            img = Image.open(self.profile_pic)

            # Resize the image
            output_size = (300, 300)
            img.thumbnail(output_size)

            # Convert to WebP
            thumb_io = BytesIO()
            img.save(thumb_io, 'WEBP', quality=85)

            # Create a new Django file-like object to save
            new_image_name = self.profile_pic.name.split('.')[0] + '.webp'
            self.profile_pic.save(new_image_name, ContentFile(thumb_io.getvalue()), save=False)

        super().save(*args, **kwargs)


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()


class Topic(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class Post(models.Model):
    topic = models.ForeignKey(Topic, related_name='posts', on_delete=models.CASCADE)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Post by {self.author.username} in {self.topic.title}'
