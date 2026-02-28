import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = ["menu"];

  menuTarget!: HTMLElement;

  toggle(): void {
    this.menuTarget.classList.toggle("site-nav-open");
  }

  close(): void {
    this.menuTarget.classList.remove("site-nav-open");
  }
}
