import {Controller} from "@hotwired/stimulus";

export default class extends Controller<HTMLInputElement> {
  override connect(): void {
    this.element.value = new Intl.DateTimeFormat().resolvedOptions().timeZone;
  }
}
