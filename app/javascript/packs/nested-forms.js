export function addFields() {
  document.removeEventListener('click', handleAddFields);
  document.addEventListener('click', handleAddFields);
}

function handleAddFields(event) {
  if (event.target && event.target.classList.contains('add_fields')) {
    event.preventDefault();
    let time = new Date().getTime();
    let link = event.target;
    let regexp = new RegExp(link.dataset.id, 'g');
    document.querySelector('#images').insertAdjacentHTML('beforeend', link.dataset.fields.replace(regexp, time));
  }
}

export function removeFields() {
  document.removeEventListener('click', handleRemoveFields);
  document.addEventListener('click', handleRemoveFields);
}

function handleRemoveFields(event) {
  if (event.target && event.target.classList.contains('remove_fields')) {
    event.preventDefault();
    let field = event.target.closest('.nested-fields');
    let destroyField = field.querySelector('input[type="hidden"][name*="_destroy"]');
    if (destroyField) {
      destroyField.value = '1';
    }
    field.style.display = 'none';
  }
}