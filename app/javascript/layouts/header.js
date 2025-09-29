document.addEventListener("DOMContentLoaded", () => {
  const slider = document.getElementById("header-slider");
  const slideTrack = document.createElement("div");
  slideTrack.className = "slide-track";
  slider.appendChild(slideTrack);

  const images = [...window.headerImages];
  const imgWidth = 200;
  let lastSrc = null;

  const sliderWidth = slider.getBoundingClientRect().width; // 固定幅
  let x = 0;   
  const speed = 0.5;

  function addImage() {
    let src;
    do {
      src = images[Math.floor(Math.random() * images.length)];
    } while (src === lastSrc);
    lastSrc = src;

    const img = document.createElement("img");
    img.src = src;
    img.style.width = `${imgWidth}px`;
    img.style.height = "200px";
    img.style.objectFit = "cover";
    slideTrack.appendChild(img);
  }

  // 最初に少しだけ画像を追加しておく
  const initialCount = Math.ceil(sliderWidth / imgWidth);
  for (let i = 0; i < initialCount; i++) addImage();

  function animate() {
    x -= speed;

    // 左端を超えた画像は削除
    const firstImg = slideTrack.children[0];
    if (firstImg && firstImg.getBoundingClientRect().right < 0) {
      slideTrack.removeChild(firstImg);      // 左端を削除
      x += imgWidth;                          // 補正してカクつきをなくす
    }

    const lastImg = slideTrack.lastElementChild;
    if (lastImg && lastImg.getBoundingClientRect().right < slider.getBoundingClientRect().right) {
      addImage()
    }

    slideTrack.style.transform = `translateX(${x}px)`;
    requestAnimationFrame(animate);
  }

  animate();
});
