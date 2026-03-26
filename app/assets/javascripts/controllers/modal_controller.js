import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  close(event) {
    // Close modal when clicking overlay (not panel)
    if (event.target === event.currentTarget) {
      window.history.back() // Or: Turbo.visit(this.element.dataset.returnUrl)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  connect() {
    // Prevent body scroll when modal open
    document.body.style.overflow = "hidden"
  }

  disconnect() {
    // Restore body scroll when modal closes
    document.body.style.overflow = ""
  }
}
