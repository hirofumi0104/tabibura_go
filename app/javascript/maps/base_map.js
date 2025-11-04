export const createBaseMap = (elementId) => {
  const element = document.getElementById(elementId);
  if (!element) return null;

  const map = L.map(elementId, {
    center: [35.6895, 139.6917],
    zoom: 10,
    maxBounds: [
      [20, 122],
      [46, 154],
    ],
    maxBoundsViscosity: 1.0,
  });
  
   const geoapifyApiKey = "b1c158a7a04d4b96b06fa1f611e096f3";

  L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19,
    minZoom: 4,
  }).addTo(map);

  return map;
};
