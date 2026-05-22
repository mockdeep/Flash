import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override values = {message: String};

  messageValue!: string;

  confirm(event: SubmitEvent): void {
    // eslint-disable-next-line no-alert
    if (!window.confirm(this.messageValue)) {
      event.preventDefault();
    }
  }
}
