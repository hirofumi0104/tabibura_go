// Entry point for the build script in your package.json

import * as ActiveStorage from "@rails/activestorage"
import { addFields, removeFields } from "./modules/nested-forms"; // nested-forms.js から関数をインポート
ActiveStorage.start()

document.addEventListener('turbo:load', () => { 
  addFields();
  removeFields();
});