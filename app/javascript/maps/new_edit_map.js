import { createBaseMap } from "./base_map";

document.addEventListener("DOMContentLoaded", () => {
  const map = createBaseMap("new-edit-map");
  const geoapifyApiKey = "b1c158a7a04d4b96b06fa1f611e096f3";

  const markers = [];          // ユーザーが追加したピン
  let itineraryMarker = null;  // セレクトで選ばれた場所のピン
  let initialMarker = null;    // 最初に表示するピン（東京駅）
  
  // ピンの状態を他でも使えるように格納
  window.newMapPins = { markers: [], initialMarker: null };

  // ピンに削除イベントとpopupをつける共通処理
  const decorateMarker = (marker, label) => {
    const popup = L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
      .setContent(label);

    marker.bindPopup(popup).openPopup();

    marker.on("click", () => {
      map.removeLayer(marker);

      // markers 配列から削除
      const idx = markers.indexOf(marker);
      if (idx !== -1) markers.splice(idx, 1);

      // window.newMapPins からも削除
      const idx2 = window.newMapPins.markers.findIndex(m => m.marker === marker);
      if (idx2 !== -1) window.newMapPins.markers.splice(idx2, 1);
    });

    marker.on("dragend", () => console.log("ピン移動後:", marker.getLatLng()));

    return marker;
  };

  // ピン追加処理
  const addMarker = (latlng, defaultLabel = "ユーザー追加ピン") => {
    const marker = L.marker(latlng, { draggable: true }).addTo(map);
    const userLabel = prompt("ピンのラベルを入力してください:", defaultLabel) || defaultLabel;

    decorateMarker(marker, userLabel);

    window.newMapPins.markers.push({
      marker,    
      latlng: marker.getLatLng(),
      label: userLabel,
    });

    markers.push(marker);

    return marker;
  };
  
  // 既存のピンをwindow.newMapPinsへ渡す処理
  const showExistingMarker = (latlng, label) => {
    const marker = L.marker(latlng, { draggable: true }).addTo(map);

    decorateMarker(marker, label);

    window.newMapPins.markers.push({
      marker,
      latlng: marker.getLatLng(),
      label: label,
    });

    markers.push(marker);

    return marker;
  };

  // 初期ピン
  const tokyoStation = [35.681236, 139.767125];
  initialMarker = L.marker(tokyoStation, { draggable: true }).addTo(map);
  initialMarker.bindPopup(
    L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
      .setContent("旅先の選択をしてください")
  ).openPopup();

  initialMarker.on("click", () => map.removeLayer(initialMarker));

  //  地域セレクトでピン表示
  const itinerarySelect = document.getElementById("itinerary_select");
  itinerarySelect.addEventListener("change", async () => {
    const placeName = itinerarySelect.value;
    if (!placeName) return;

    if (initialMarker) { map.removeLayer(initialMarker); initialMarker = null; }
    if (itineraryMarker) { map.removeLayer(itineraryMarker); itineraryMarker = null; }

    try {
      const url = `https://api.geoapify.com/v1/geocode/search?text=${encodeURIComponent(placeName)},Japan&apiKey=${geoapifyApiKey}`;
      const res = await fetch(url);
      const data = await res.json();

      if (data.features?.length) {
        const [lon, lat] = data.features[0].geometry.coordinates;
        itineraryMarker = L.marker([lat, lon], { draggable: true }).addTo(map);
        itineraryMarker.bindPopup(
          L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
            .setContent(placeName)
        ).openPopup();

        itineraryMarker.on("click", () => map.removeLayer(itineraryMarker));
        map.setView([lat, lon], 10);

        window.newMapPins.itineraryMarker = {
          latlng: { lat, lng: lon },
          label: placeName,
        };
      }
    } catch (err) {
      console.error("itineraryピン表示失敗:", err);
    }
  });

  //  検索ピン
  const searchInput = document.getElementById("location");
  window.searchLocation = async () => {
    const query = searchInput.value;
    if (!query) return alert("検索ワードを入力してください");

    try {
      const url = `https://api.geoapify.com/v1/geocode/search?text=${encodeURIComponent(query)}&apiKey=${geoapifyApiKey}`;
      const res = await fetch(url);
      const data = await res.json();

      if (data.features?.length) {
        const [lon, lat] = data.features[0].geometry.coordinates;
        addMarker([lat, lon], query);
        map.setView([lat, lon], 15);
      } else {
        alert("該当する場所が見つかりませんでした");
      }
    } catch (err) {
      console.error("検索ピン表示失敗:", err);
    }
  };
   
  // 既存ピンの再表示（編集画面用）
  const mapContainer = document.getElementById("new-edit-map");
  if (mapContainer && mapContainer.dataset.pins) {
    try {
      const pins = JSON.parse(mapContainer.dataset.pins);

      pins.forEach((pin) => {
        showExistingMarker([pin.latitude, pin.longitude], pin.label);
      });

      if (pins.length > 0) {
        const firstPin = pins[0];
        map.setView([firstPin.latitude, firstPin.longitude], 10);
      }
    } catch (err) {
      console.error("既存ピンの読み込み失敗:", err);
    }
  }

  //  previewにピン追加
  map.on("click", (e) => addMarker(e.latlng));
});
