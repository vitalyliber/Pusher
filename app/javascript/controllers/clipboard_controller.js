import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"];
  static values = {
    textToCopy: { type: String, default: "Text to copy" },
    originalText: { type: String, default: "Copy" },
    copiedText: { type: String, default: "Copied" },
    timeout: { type: Number, default: 2000 },
  };

  connect() {
    this.textTarget.textContent = this.originalTextValue;
  }

  copy() {
    navigator.clipboard
      .writeText(this.textToCopyValue)
      .then(() => {
        this.textTarget.textContent = this.copiedTextValue;

        setTimeout(() => {
          this.textTarget.textContent = this.originalTextValue;
        }, this.timeoutValue);
      })
      .catch((err) => {
        console.error("Failed to copy: ", err);
      });
  }
}
