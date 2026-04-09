import {Controller} from "@hotwired/stimulus";

import {assert} from "helpers/assert";

function resolveKey(key: string): string {
  if (key === "Enter") { return " "; }
  return key;
}

function isFormField(target: EventTarget | null): boolean {
  return (
    target instanceof HTMLInputElement ||
    target instanceof HTMLTextAreaElement ||
    target instanceof HTMLSelectElement
  );
}

function isBehindDialog(element: HTMLElement): boolean {
  const dialog = document.querySelector("dialog[open]");

  return dialog !== null && !dialog.contains(element);
}

export default class extends Controller {
  static override targets = ["click"];

  clickTargets!: HTMLElement[];

  indexedClickTargets = new Map<string, HTMLElement>();

  clickTargetConnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.set(assert(hotkey), element);
  }

  clickTargetDisconnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.delete(assert(hotkey));
  }

  handleKeydown(event: KeyboardEvent): void {
    if (isFormField(event.target)) { return; }

    const clickable = this.indexedClickTargets.get(resolveKey(event.key));

    if (!clickable) { return; }
    if (isBehindDialog(clickable)) { return; }

    event.preventDefault();
    clickable.click();
  }
}
