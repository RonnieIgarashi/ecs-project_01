function toggleEditMode() {
    const isEditing = document.body.classList.toggle('edit-mode');
    document.getElementById('btn-edit').textContent = isEditing ? '編集モード（解除）' : '編集モード';
    if (!isEditing) {
        document.querySelectorAll('.delete-check').forEach(cb => cb.checked = false);
        document.getElementById('btn-delete').style.display = 'none';
    }
}

function updateDeleteBtn() {
    const anyChecked = document.querySelectorAll('.delete-check:checked').length > 0;
    document.getElementById('btn-delete').style.display = anyChecked ? 'inline-block' : 'none';
}

function confirmDelete() {
    document.getElementById('delete-modal').classList.add('show');
}

function closeModal() {
    document.getElementById('delete-modal').classList.remove('show');
}

function deleteChecked() {
    closeModal();
    const ids = [];
    const newRows = [];
    document.querySelectorAll('.delete-check:checked').forEach(cb => {
        const row = cb.closest('tr');
        const id = row.getAttribute('data-id');
        if (id) {
            ids.push(parseInt(id));
        } else {
            newRows.push(row);
        }
    });
    newRows.forEach(row => row.remove());
    updateDeleteBtn();

    if (ids.length === 0) return;

    fetch('/delete/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken'),
        },
        body: JSON.stringify({ ids }),
    })
    .then(res => res.json())
    .then(data => {
        if (data.status === 'ok') {
            window.location.reload();
        } else {
            alert('削除に失敗しました: ' + (data.message || ''));
        }
    })
    .catch(() => alert('削除中にエラーが発生しました。'));
}

function addRow() {
    const options = statusOptions
        .map(o => `<option value="${escHtml(o.value)}">${escHtml(o.label)}</option>`)
        .join('');
    const tr = document.createElement('tr');
    tr.setAttribute('data-id', '');
    tr.innerHTML = `
        <td>
            <span class="view-cell"></span>
            <input class="edit-cell delete-check" type="checkbox" onchange="updateDeleteBtn()">
        </td>
        <td>
            <span class="view-cell"></span>
            <input class="edit-cell" type="text" value="" data-field="title">
        </td>
        <td>
            <span class="view-cell"></span>
            <input class="edit-cell" type="text" value="" data-field="author">
        </td>
        <td>
            <span class="view-cell"></span>
            <input class="edit-cell" type="text" value="" data-field="publisher">
        </td>
        <td>
            <span class="view-cell"></span>
            <textarea class="edit-cell" data-field="note"></textarea>
        </td>
        <td>
            <span class="view-cell"></span>
            <select class="edit-cell" data-field="status">${options}</select>
        </td>
    `;
    document.getElementById('book-tbody').appendChild(tr);
}

function saveBooks() {
    const books = [];
    document.querySelectorAll('#book-tbody tr').forEach(row => {
        const id = row.getAttribute('data-id') || null;
        const fields = {};
        row.querySelectorAll('.edit-cell').forEach(el => {
            fields[el.getAttribute('data-field')] = el.value;
        });
        books.push({
            id: id ? parseInt(id) : null,
            title: fields.title || '',
            author: fields.author || '',
            publisher: fields.publisher || '',
            note: fields.note || '',
            status: fields.status || '',
        });
    });

    fetch('/save/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken'),
        },
        body: JSON.stringify({ books }),
    })
    .then(res => res.json())
    .then(data => {
        if (data.status === 'ok') {
            window.location.reload();
        } else {
            alert('保存に失敗しました: ' + (data.message || ''));
        }
    })
    .catch(() => alert('保存中にエラーが発生しました。'));
}

function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
    return '';
}

function escHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
