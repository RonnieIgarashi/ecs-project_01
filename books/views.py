import json
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.http import JsonResponse, HttpResponse
from .models import Book


def health(request):
    return HttpResponse('OK')


@login_required
def index(request):
    books = list(Book.objects.all())
    return render(request, 'books/index.html', {
        'books': books,
        'status_choices': Book.STATUS_CHOICES,
    })


@login_required
@require_POST
def save_books(request):
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)

    for row in data.get('books', []):
        book_id = row.get('id')
        title = (row.get('title') or '').strip()
        author = (row.get('author') or '').strip()
        publisher = (row.get('publisher') or '').strip() or None
        note = (row.get('note') or '').strip() or None
        status = (row.get('status') or '').strip() or None

        if not title and not author:
            continue

        if book_id:
            Book.objects.filter(id=book_id).update(
                title=title, author=author,
                publisher=publisher, note=note, status=status,
            )
        else:
            Book.objects.create(
                title=title, author=author,
                publisher=publisher, note=note, status=status,
            )

    return JsonResponse({'status': 'ok'})


@login_required
@require_POST
def delete_books(request):
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)

    ids = [int(i) for i in data.get('ids', []) if i]
    if ids:
        Book.objects.filter(id__in=ids).delete()
    return JsonResponse({'status': 'ok'})
