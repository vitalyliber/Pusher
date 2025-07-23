import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="json-input-persister" data-action="input->json-input-persister#save"
// controllers/json_input_persister_controller.js
import JSONEditor from "jsoneditor";

export default class extends Controller {
  static values = { key: String };

  connect() {
    this.initializeJsonEditor();
    this.load();
  }

  initializeJsonEditor() {
    const container = this.element.querySelector("#jsoneditor");
    this.hiddenInput = this.element.querySelector("#data");

    const options = {
      onChangeText: (jsonString) => {
        try {
          this.hiddenInput.value = jsonString;
          this.save();
        } catch (e) {
          console.error("Invalid JSON:", e);
          this.hiddenInput.value = "";
        }
      },
    };

    this.editor = new JSONEditor(container, options);

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

    if (!this.hiddenInput.value) {
      this.editor.set(initialJson);
      this.hiddenInput.value = JSON.stringify(initialJson);
    }
  }

  save() {
    localStorage.setItem(this.getStorageKey(), this.hiddenInput.value);
  }

  load() {
    const savedValue = localStorage.getItem(this.getStorageKey());
    if (savedValue !== null) {
      try {
        const parsedJson = JSON.parse(savedValue);
        this.editor.set(parsedJson);
        this.hiddenInput.value = savedValue;
      } catch (e) {
        console.error("Failed to parse saved JSON:", e);
      }
    }
  }

  getStorageKey() {
    // Unique key based on data-input-persister-key, id or name
    return (
      this.element.dataset.inputPersisterKey ||
      this.hiddenInput.id ||
      this.hiddenInput.name
    );
  }
}
