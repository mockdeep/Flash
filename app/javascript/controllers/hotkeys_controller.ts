import {Controller} from "@hotwired/stimulus";

import {assert} from "helpers/assert";

const CTRL_PREFIX = "ctrl+";
const ALT_PREFIX = "alt+";

function resolveEvent(event: KeyboardEvent): string {
  const hasCtrl = event.ctrlKey || event.metaKey;
  let {key} = event;

  if (!hasCtrl && !event.altKey && key === "Enter") { key = " "; }
  if (event.altKey) { key = ALT_PREFIX + key; }
  if (hasCtrl) { key = CTRL_PREFIX + key; }

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
    const key = resolveEvent(event);
    const clickable = this.indexedClickTargets.get(key);

    if (!clickable) { return; }
    if (!key.startsWith(CTRL_PREFIX) && isFormField(event.target)) { return; }
    if (isBehindDialog(clickable)) { return; }

    event.preventDefault();
    clickable.click();
  }
}
