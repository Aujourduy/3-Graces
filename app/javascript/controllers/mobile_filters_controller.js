import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel"]

  connect() {
    // Listen for Esc key to close filters
    this.escapeHandler = this.handleEscape.bind(this)
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("hidden")

    // Update aria-hidden for accessibility
    this.panelTarget.setAttribute("aria-hidden", "false")
    this.overlayTarget.setAttribute("aria-hidden", "false")

    // Add Esc key listener
    document.addEventListener("keydown", this.escapeHandler)
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    this.panelTarget.classList.add("hidden")

    // Update aria-hidden
    this.panelTarget.setAttribute("aria-hidden", "true")
    this.overlayTarget.setAttribute("aria-hidden", "true")

    // Remove Esc key listener
    document.removeEventListener("keydown", this.escapeHandler)
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    // Cleanup listener when controller is removed
    document.removeEventListener("keydown", this.escapeHandler)
  }
}
