import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = ["toggle", "panel"];

  declare toggleTarget: HTMLButtonElement;

  declare panelTarget: HTMLElement;

  private isOpen = false;

  toggle(): void {
    this.setOpen(!this.isOpen);
  }

  close(): void {
    this.setOpen(false);
  }

  handleDocClick(event: MouseEvent): void {
    if (!this.isOpen) { return; }
    if (!(event.target instanceof Node)) { return; }
    if (this.element.contains(event.target)) { return; }
    this.setOpen(false);
  }

  handleEsc(event: KeyboardEvent): void {
    if (event.key !== "Escape") { return; }
    if (!this.isOpen) { return; }
    this.setOpen(false);
  }

  private setOpen(open: boolean): void {
    this.isOpen = open;
    this.panelTarget.hidden = !open;
    this.toggleTarget.setAttribute("aria-expanded", String(open));
  }
}
