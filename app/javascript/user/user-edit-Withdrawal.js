document.addEventListener("DOMContentLoaded", function() {
  const withdrawalCheckbox = document.querySelector('#withdrawal_confirmation');
  const updateButton = document.querySelector('.primary-button');
  const withdrawalButtonLink = document.querySelector('#withdrawal-button a');

  if (!withdrawalCheckbox || !updateButton || !withdrawalButtonLink) return;

  const toggleButton = () => {
    if (withdrawalCheckbox.checked) {
      // ボタンの表示テキストを退会に変更
      updateButton.value = withdrawalButtonLink.textContent;

      // クラスも退会ボタンに変更
      updateButton.className = withdrawalButtonLink.className;

      // ボタンを退会用リンクに変える
      updateButton.onclick = (e) => {
        e.preventDefault();
        if (confirm("本当に退会しますか？")) {
          withdrawalButtonLink.click(); 
        }
      };
    } else {
      updateButton.value = "更新";
      updateButton.className = 'primary-button';
      updateButton.onclick = null;
    }
  };

  toggleButton();
  withdrawalCheckbox.addEventListener('change', toggleButton);
});
