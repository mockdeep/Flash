import {Controller} from "@hotwired/stimulus";
import {visit} from "@hotwired/turbo";

const DELAY_MS = 1000;

export default class extends Controller<HTMLElement> {
  static override values = {
    frame: String,
    url: String,
  };

  declare frameValue: string;

  declare urlValue: string;

  private timeoutHandle: ReturnType<typeof setTimeout> | null = null;

  override connect(): void {
    this.timeoutHandle = setTimeout(() => {
      visit(this.urlValue, {frame: this.frameValue});
    }, DELAY_MS);
  }

  override disconnect(): void {
    if (this.timeoutHandle !== null) {
      clearTimeout(this.timeoutHandle);
      this.timeoutHandle = null;
    }
  }
}
