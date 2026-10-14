import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

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

const UNTYPED_INPUTS = ["checkbox", "radio"];

/*
 * Fields the user types into. A focused radio, such as the Study | Read tab
 * just clicked, takes no text, so hotkeys still apply.
 */
function isFormField(target: EventTarget | null): boolean {
  if (target instanceof HTMLInputElement) {
    return !UNTYPED_INPUTS.includes(target.type);
  }

  return (
    target instanceof HTMLTextAreaElement ||
    target instanceof HTMLSelectElement
  );
}

function isBehindDialog(element: HTMLElement): boolean {
  const dialog = document.querySelector("dialog[open]");

  return dialog !== null && !dialog.contains(element);
}

/*
 * Only ancestors count: a target may itself be hidden on purpose, like the
 * study page's span that claims the space key to stop scrolling.
 */
function isInHiddenSection(element: HTMLElement): boolean {
  for (let el = element.parentElement; el; el = el.parentElement) {
    if (getComputedStyle(el).display === "none") { return true; }
  }

  return false;
}

function isOutOfView(element: HTMLElement): boolean {
  return isBehindDialog(element) || isInHiddenSection(element);
}

export default class extends Controller {
  static override targets = ["click"];

  declare clickTargets: HTMLElement[];

  indexedClickTargets = new Map<string, HTMLElement>();

  clickTargetConnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.set(ensure(hotkey), element);
  }

  clickTargetDisconnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.delete(ensure(hotkey));
  }

  handleKeydown(event: KeyboardEvent): void {
    const key = resolveEvent(event);
    const clickable = this.indexedClickTargets.get(key);

    if (!clickable) { return; }
    if (!key.startsWith(CTRL_PREFIX) && isFormField(event.target)) { return; }
    if (isOutOfView(clickable)) { return; }

    event.preventDefault();
    clickable.click();
  }
}
