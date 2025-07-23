import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input-persister" data-action="input->input-persister#save"
export default class extends Controller {
   connect() {
    this.load()
  }

  save(event) {
    localStorage.setItem(this.getStorageKey(), this.element.value)
  }

  load() {
    const value = localStorage.getItem(this.getStorageKey())
    if (value !== null) {
      this.element.value = value
    }
  }

  getStorageKey() {
    // Unique key based on data-input-persister-key, id or name
    return this.element.dataset.inputPersisterKey || this.element.id || this.element.name
  }
}
