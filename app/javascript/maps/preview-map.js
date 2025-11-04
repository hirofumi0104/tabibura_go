import { createBaseMap } from "./base_map";

document.addEventListener("DOMContentLoaded", () => {
  const modal = document.getElementById("preview-modal");
  let previewMap = null;

  // モーダルが開いた瞬間にマップを作成・更新
  const openBtn = document.getElementById("preview-btn");
  openBtn.addEventListener("click", () => {
    // マップ用のDOMが見えるようになるまで少し待つ
    setTimeout(() => {
      const mapContainer = document.getElementById("preview-map");
      if (!mapContainer) return;

      // 既に地図が存在する場合は削除して再生成
      if (previewMap) {
        previewMap.remove();
        previewMap = null;
      }

      previewMap = createBaseMap("preview-map");

      if (window.newMapPins) {
        const { markers = [], itineraryMarker } = window.newMapPins;

        // 通常ピン追加
        markers.forEach(pin => {
          L.marker(pin.latlng).addTo(previewMap).bindPopup(pin.label);
        });

        // 都道府県ピン
        if (itineraryMarker) {
          L.marker(itineraryMarker.latlng)
            .addTo(previewMap)
            .bindPopup(itineraryMarker.label);
        }

        // どのピンを中心にするか決定
        const centerPin = itineraryMarker?.latlng || markers[0]?.latlng;
        if (centerPin) {
          previewMap.setView(centerPin, 10);
        }

        // モーダル内で正しく表示されるようサイズ再計算
        setTimeout(() => {
          previewMap.invalidateSize();
        }, 200);
      } else {
        console.warn("ピンの情報が存在しません！");
      }
    }, 200); // モーダル描画完了を待ってから
  });
});
