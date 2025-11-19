// 詳細画面のマップ表示のJS

import { createBaseMap } from "./base_map";

document.addEventListener("DOMContentLoaded", () => {
  const showMapContainer = document.getElementById("show-map");
  const showMap = createBaseMap("show-map");

  const savedMapPins = JSON.parse(showMapContainer.dataset.mapPins || "[]");

  savedMapPins.forEach((pin) => {
    const marker = L.marker([pin.latlng.lat, pin.latlng.lng]).addTo(showMap);
    marker.bindPopup(L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
                     .setContent(pin.label)).openPopup();
  });
  
  // 画面の自動調整
  if (savedMapPins.length > 0) {
    const bounds = L.latLngBounds(savedMapPins.map(p => [p.latlng.lat, p.latlng.lng]));
    showMap.fitBounds(bounds);
  }
});
