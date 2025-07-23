import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="json-input-persister" data-action="input->json-input-persister#save"
// controllers/json_input_persister_controller.js
import JSONEditor from "jsoneditor";

export default class extends Controller {
  static targets = ["editor", "input"];
  static values = { key: String };

  connect() {
    this.initializeJsonEditor();
    this.load();
  }

  initializeJsonEditor() {
    const options = {
      onChangeText: (jsonString) => {
        try {
          this.inputTarget.value = jsonString;
          this.save();
        } catch (e) {
          console.error("Invalid JSON:", e);
          this.inputTarget.value = "";
        }
      },
    };

    this.editor = new JSONEditor(this.editorTarget, options);

    const initialJson = {
      notification: {
        title: "Hey",
        body: ":)",
      },
      data: {
        key1: "value1",
        key2: "value2",
      },
    };

    if (!this.inputTarget.value) {
      this.editor.set(initialJson);
      this.inputTarget.value = JSON.stringify(initialJson);
    }
  }

  save() {
    localStorage.setItem(this.getStorageKey(), this.inputTarget.value);
  }

  load() {
    const savedValue = localStorage.getItem(this.getStorageKey());
    if (savedValue !== null) {
      try {
        const parsedJson = JSON.parse(savedValue);
        this.editor.set(parsedJson);
        this.inputTarget.value = savedValue;
      } catch (e) {
        console.error("Failed to parse saved JSON:", e);
      }
    }
  }

  getStorageKey() {
    return (
      this.element.dataset.inputPersisterKey ||
      this.inputTarget.id ||
      this.inputTarget.name
    );
  }
}
