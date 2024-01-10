import { Controller } from '@hotwired/stimulus'

// Connects to data-controller='programming-languages--search'
export default class extends Controller {
  static targets = ['query']

  apply() {
    const query = encodeURIComponent(this.queryTarget.value)

    const params = `query=${query}`

    fetch(`/programming_languages/search?${params}`, {
      headers: {'Accept': 'text/vnd.turbo-stream.html'}})
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
    .catch(error => console.log(error))
  }
}