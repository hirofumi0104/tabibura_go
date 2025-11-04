// Entry point for the build script in your package.json

import * as ActiveStorage from "@rails/activestorage"
import Rails from "@rails/ujs";

// publicの画面で使用するJS
import "./layouts/header";
// 投稿画面で使用するJS
import "./post_screen/preview";
import { addFields, removeFields } from "./modules/nested-forms";
// map表示用JS
import "./maps/show_map";
import "./maps/new_map";
import "./maps/preview-map";
import "./maps/edit_map";


Rails.start();
ActiveStorage.start()

document.addEventListener('DOMContentLoaded', () => { 
  addFields();
  removeFields();
});