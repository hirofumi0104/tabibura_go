// 「レポート追加」ボタンのイベント設定
export function addFields() {
  document.removeEventListener('click', handleAddFields); // 重複登録防止
  document.addEventListener('click', handleAddFields);
}

// フィールド追加処理
function handleAddFields(event) {
  if (event.target && event.target.classList.contains('add_fields')) {
    event.preventDefault();
    let time = new Date().getTime();
    let link = event.target;
    let regexp = new RegExp(link.dataset.id, 'g');
    document
      .querySelector('#images')
      .insertAdjacentHTML('beforeend', link.dataset.fields.replace(regexp, time));
  }
}

// 「レポート削除」ボタンのイベント設定
export function removeFields() {
  document.removeEventListener('click', handleRemoveFields); // 重複登録防止
  document.addEventListener('click', handleRemoveFields);
}

// フィールド削除処理
function handleRemoveFields(event) {
  if (event.target && event.target.classList.contains('remove_fields')) {
    event.preventDefault();
    let field = event.target.closest('.nested-fields');
    let destroyField = field.querySelector('input[type="hidden"][name*="_destroy"]');
    if (destroyField) destroyField.value = '1';
    field.style.display = 'none';
  }
}
