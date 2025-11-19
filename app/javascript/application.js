// Entry point for the build script in your package.json

import * as ActiveStorage from "@rails/activestorage"
import Rails from "@rails/ujs";

// publicの画面で使用するJS
import "./layouts/header";
// 投稿画面でレポート枠を増やすJS
import "./post_screen/preview";
import { addFields, removeFields } from "./modules/nested-forms";
// ユーザー情報変更画面の退会ボタン表示のJS
import "./user/user-edit-Withdrawal"
// map表示用JS
import "./maps/show_map";
import "./maps/new_edit_map";
import "./maps/preview-map";
// mapピンの経度、緯度、ラベル詰めるJS
import "./maps/map_pins_form"


Rails.start();
ActiveStorage.start()

document.addEventListener('DOMContentLoaded', () => { 
  addFields();
  removeFields();
});