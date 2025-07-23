import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["frame", "input"];

  connect() {
    setTimeout(() => {
      this.setQuery(this.inputTarget.value);
    }, 500);
  }

  search(event) {
    console.log("Search initiated with query:", event.target.value);
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      const query = event.target.value;
      if (query) {
        this.setQuery(query);
      } else {
        this.frameTarget.innerHTML = "<p>...</p>";
      }
    }, 300);
  }

  setQuery(query) {
    this.frameTarget.setAttribute(
      "src",
      `/notifications/search_mobile_devices?query=${encodeURIComponent(query)}`
    );
  }
}
