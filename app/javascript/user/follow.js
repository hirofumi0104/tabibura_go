// app/javascript/packs/common_ajax.js など
document.addEventListener("DOMContentLoaded", () => {
  document.addEventListener("ajax:success", (event) => {
    const data = event.detail[0];
    if (!data.target_class || !data.html) return;

    // どのボタンでも同じ処理で更新
    document.querySelectorAll(`.${data.target_class}`).forEach((element) => {
      element.innerHTML = data.html;
    });
  });
});