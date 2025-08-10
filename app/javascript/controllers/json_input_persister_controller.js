import { Controller } from "@hotwired/stimulus";
import JSONEditor from "jsoneditor";

export default class extends Controller {
  static targets = ["editor", "input"];
  static values = { key: String };

  connect() {
    this.initializeJsonEditor();
    this.load();
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy();
      this.editor = null;
    }
  }

  initializeJsonEditor() {
    if (this.editor) {
      this.editor.destroy();
    }

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
    } else {
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
      this.editor.set(initialJson);
      this.inputTarget.value = JSON.stringify(initialJson);
    }
    this.editor.expandAll();
  }

  getStorageKey() {
    return (
      this.element.dataset.inputPersisterKey ||
      this.inputTarget.id ||
      this.inputTarget.name
    );
  }

  // Paste JSON from clipboard
  async pasteJson(event) {
    event.preventDefault();

    if (!confirm("Are you sure you want to read JSON from the clipboard?")) {
      return;
    }

    try {
      const text = await navigator.clipboard.readText();
      let jsonData;

      // Validate JSON
      try {
        jsonData = JSON.parse(text);
      } catch (e) {
        alert("Error: Clipboard contains invalid JSON");
        return;
      }

      // Set valid JSON in editor
      this.editor.set(jsonData);
      this.inputTarget.value = JSON.stringify(jsonData);
      this.save();
      this.editor.expandAll();
    } catch (e) {
      alert("Error reading from clipboard");
      console.error("Clipboard read error:", e);
    }
  }

  // Copy JSON to clipboard
  async copyJson(event) {
    event.preventDefault();
    try {
      const jsonString = this.inputTarget.value;

      // Validate JSON before copying
      try {
        JSON.parse(jsonString);
      } catch (e) {
        alert("Error: Cannot copy invalid JSON");
        return;
      }

      await navigator.clipboard.writeText(jsonString);

      // Store original button text
      const button = event.target;
      const originalText = button.textContent;

      // Change button text for 2 seconds
      button.textContent = "Copied!";
      button.disabled = true;

      setTimeout(() => {
        button.textContent = originalText;
        button.disabled = false;
      }, 2000);
    } catch (e) {
      alert("Error copying to clipboard");
      console.error("Clipboard write error:", e);
    }
  }
}
