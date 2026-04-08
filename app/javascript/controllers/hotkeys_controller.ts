import {Controller} from "@hotwired/stimulus";

import {assert} from "helpers/assert";

function resolveKey(key: string): string {
  if (key === "Enter") { return " "; }
  return key;
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
    const {key} = event;
    const clickable = this.indexedClickTargets.get(resolveKey(key));

    if (clickable) {
      event.preventDefault();
      clickable.click();
    }
  }
}
