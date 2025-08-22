import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "counter", "submitButton"]
  static values = { maxLength: Number }

  connect() {
    this.updateCounter()
  }

  updateCounter() {
    const remaining = this.maxLengthValue - this.textareaTarget.value.length
    this.counterTarget.textContent = `${remaining} characters remaining`

    // Update counter color based on remaining characters
    if (remaining < 0) {
      this.counterTarget.classList.add('text-red-600')
      this.counterTarget.classList.remove('text-blue-600')
      this.submitButtonTarget.disabled = true
    } else if (remaining <= 20) {
      this.counterTarget.classList.add('text-yellow-600')
      this.counterTarget.classList.remove('text-blue-600', 'text-red-600')
      this.submitButtonTarget.disabled = false
    } else {
      this.counterTarget.classList.add('text-blue-600')
      this.counterTarget.classList.remove('text-yellow-600', 'text-red-600')
      this.submitButtonTarget.disabled = false
    }
  }
}
