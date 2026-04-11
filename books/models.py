from django.db import models


class Book(models.Model):
    STATUS_CHOICES = [
        ('unread', '未読'),
        ('reading', '読書中'),
        ('read', '読了'),
        ('sold', '販売済み'),
        ('disposed', '廃棄'),
        ('lost', '紛失'),
        ('transferred', '譲渡'),
        ('other', 'その他'),
    ]

    title = models.CharField(max_length=255)
    author = models.CharField(max_length=255)
    publisher = models.CharField(max_length=255, null=True, blank=True)
    note = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, null=True, blank=True)

    class Meta:
        db_table = 'books'
        ordering = ['id']

    def __str__(self):
        return self.title
