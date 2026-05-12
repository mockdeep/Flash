import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = ["button"];

  static override values = {url: String};

  buttonTarget!: HTMLButtonElement;

  urlValue!: string;

  async copy(): Promise<void> {
    const {textContent: original} = this.buttonTarget;

    await navigator.clipboard.writeText(this.urlValue);

    this.buttonTarget.textContent = "Copied!";
    setTimeout(() => {
      this.buttonTarget.textContent = original;
    }, 1500);
  }
}
