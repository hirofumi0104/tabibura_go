document.addEventListener('DOMContentLoaded', () => {
  const modal = document.getElementById('preview-modal');
  const openBtn = document.getElementById('preview-btn');
  const closeBtn = document.querySelector('.close');

  const captionInput = document.querySelector('#post_caption');
  const mainImageInput = document.querySelector('#post_main_image');
  const subImageContainers = document.querySelectorAll('.nested-fields');
  const tagInput = document.querySelector('#manual_tag_input');

  // JS 用のモーダル内要素
  const title = modal.querySelector('#post-title');
  const mainImgContainer = modal.querySelector('#post-main-img-container');
  const subImgContainer = modal.querySelector('#post-sub-imgs-container');
  const tagsContainer = modal.querySelector('#post-tags-container');
  const emptyMsg = modal.querySelector('#preview-empty');

  openBtn.addEventListener('click', () => {
    modal.style.display = 'flex';
    
    window.dispatchEvent(new Event('resize'));

    // タイトル
    title.textContent = captionInput.value;

    // メイン画像
    mainImgContainer.innerHTML = '';
    if (mainImageInput.files[0]) {
      const reader = new FileReader();
      reader.onload = e => {
        mainImgContainer.innerHTML = `<span id="post-main-img"><img src="${e.target.result}" style="width:100%; max-height:300px; object-fit:cover;"></span>`;
      };
      reader.readAsDataURL(mainImageInput.files[0]);
    }

    // サブ画像 + description
    subImgContainer.innerHTML = '';
    let hasSubContent = false;
    const subImageContainers = document.querySelectorAll('.nested-fields');

    subImageContainers.forEach(container => {
      const fileInput = container.querySelector('input[type="file"]');
      const descInput = container.querySelector('input[type="text"], textarea');
      if (fileInput && fileInput.files[0]) {
        hasSubContent = true;
        const reader = new FileReader();
        reader.onload = e => {
          const div = document.createElement('div');
          div.id = 'post-sub-img';
          div.innerHTML = `
            <img src="${e.target.result}" style="width:100%; max-height:200px; object-fit:cover;">
            <div id="post-sub-text">${descInput ? descInput.value : ''}</div>
          `;
          subImgContainer.appendChild(div);
        };
        reader.readAsDataURL(fileInput.files[0]);
      }
    });

    // タグ
    tagsContainer.innerHTML = '';
    if (tagInput.value.trim() !== '') {
      const tagList = tagInput.value.split(',').map(tag => tag.trim());
      const h5 = document.createElement('h5');
      h5.textContent = 'タグ';
      tagsContainer.appendChild(h5);
      tagList.forEach(tag => {
        const a = document.createElement('a');
        a.href = `/public/posts?tag=${tag}`;
        a.textContent = `#${tag}`;
        a.style.marginRight = '5px';
        tagsContainer.appendChild(a);
      });
    }

    // 入力がない場合
    const hasContent = captionInput.value || mainImageInput.files.length || hasSubContent || tagInput.value.trim();

    if (!hasContent) {
      emptyMsg.style.display = 'block';
      // マップ非表示（内容の入力がない場合）
      document.getElementById('preview-map').style.display = 'none';
    } else {
      emptyMsg.style.display = 'none';
      // マップ表示＆リサイズ
      const previewMap = document.getElementById('preview-map');
      previewMap.style.display = 'block';
    }
  });

  // モーダルを閉じる
  closeBtn.addEventListener('click', () => modal.style.display = 'none');
  window.addEventListener('click', e => {
    if (e.target === modal) modal.style.display = 'none';
  });
});
