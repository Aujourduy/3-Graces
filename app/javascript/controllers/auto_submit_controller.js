import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    // Submit the form automatically when any input changes
    this.element.requestSubmit()
  }
}
