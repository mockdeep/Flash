import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "icon", "text"];

  inputTarget!: HTMLInputElement;

  iconTarget!: HTMLElement;

  textTarget!: HTMLElement;

  select(): void {
    const file = this.inputTarget.files?.[0];

    if (file) {
      this.iconTarget.textContent = "✅";
      this.textTarget.textContent = file.name;
      this.element.classList.add("file-selected");
    } else {
      this.iconTarget.textContent = "📤";
      this.textTarget.textContent = "Choose CSV file or drag here";
      this.element.classList.remove("file-selected");
    }
  }
}
