import { createBaseMap } from "./base_map";

document.addEventListener("DOMContentLoaded", () => {
  const map = createBaseMap("new-map");
  const markers = [];          // ユーザー・検索で刺したピン
  let itineraryMarker = null;  // セレクトボックスの選択されたピン
  let initialMarker = null;    // 最初のピン
  const geoapifyApiKey = "b1c158a7a04d4b96b06fa1f611e096f3";
  window.newMapPins = { markers: [], initialMarker: null };  // プレビューで使用するピン情報を格納
  
  // ピン追加（ユーザー・検索ピン用）
  const addMarker = (latlng, defaultLabel = "ユーザー追加ピン") => {
    const marker = L.marker(latlng, { draggable: true }).addTo(map);

    // 置いた瞬間にラベル入力を促す
    const userLabel = prompt("ピンのラベルを入力してください:", defaultLabel) || defaultLabel;
    const popup = L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
                  .setContent(userLabel);
    marker.bindPopup(popup).openPopup();

    marker.on("click", () => {
      map.removeLayer(marker);
      const idx = markers.indexOf(marker);
      if (idx !== -1) markers.splice(idx, 1);
      window.newMapPins.markers = window.newMapPins.markers.filter(
        (m) => m.latlng.lat !== marker.getLatLng().lat || m.latlng.lng !== marker.getLatLng().lng
      );
    });

    marker.on("dragend", () => console.log("ピン移動後:", marker.getLatLng()));
    markers.push(marker);
    window.newMapPins.markers.push({
      latlng: marker.getLatLng(),
      label: userLabel
    });
    return marker;
  };

  // 初期ピン（東京駅）
  const tokyoStation = [35.681236, 139.767125];
  initialMarker = L.marker(tokyoStation, { draggable: true }).addTo(map);
  initialMarker.bindPopup(L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
                          .setContent("旅先の選択をしてください")).openPopup();
  initialMarker.on("click", () => map.removeLayer(initialMarker));

  // クリックでユーザーピン追加
  map.on("click", (e) => addMarker(e.latlng));

  // itineraryセレクトでピン表示
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
        itineraryMarker.bindPopup(L.popup({ closeOnClick: false, autoClose: false, closeButton: false })
                                .setContent(placeName)).openPopup();
        itineraryMarker.on("click", () => map.removeLayer(itineraryMarker));
        map.setView([lat, lon], 10);
        
        window.newMapPins.itineraryMarker = {
          latlng: { lat, lng: lon },
          label: placeName
        };
      }
    } catch (err) {
      console.error("itineraryピン表示失敗:", err);
    }
  });

  // 検索ピン（ユーザー扱い）
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
});
