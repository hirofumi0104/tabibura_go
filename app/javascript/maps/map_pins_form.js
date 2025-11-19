// DBにピンの緯度、経度、ラベルを保存するためのJS

document.addEventListener("DOMContentLoaded", () => {
  const postForm = document.querySelector(".post-form form");
  const container = document.querySelector(".map-pins-fields-container");

  postForm.addEventListener("submit", () => {
    container.innerHTML = ""; // バリデーションエラーで重複したので（前回分をクリア）

    window.newMapPins.markers.forEach((pin, idx) => {
      const wrapper = document.createElement("div");
      wrapper.innerHTML = `
        <input type="hidden" name="post[map_pins_attributes][${idx}][latitude]" value="${pin.latlng.lat}">
        <input type="hidden" name="post[map_pins_attributes][${idx}][longitude]" value="${pin.latlng.lng}">
        <input type="hidden" name="post[map_pins_attributes][${idx}][label]" value="${pin.label}">
      `;
      container.appendChild(wrapper);
    });
  });
});

