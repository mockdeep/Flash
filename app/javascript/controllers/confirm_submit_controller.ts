import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override values = {message: String};

  declare messageValue: string;

  confirm(event: SubmitEvent): void {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault();
    }
  }
}
