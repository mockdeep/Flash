import {Controller} from "@hotwired/stimulus";
import {findEl} from "helpers/find_el";

export default class extends Controller {
  static override values = {url: String};

  declare urlValue: string;

  async record(event: {params: {senseId: number}}): Promise<void> {
    const {content: token} = findEl(document, "meta", "[name='csrf-token']");
    const body = new FormData();
    body.append("sense_id", String(event.params.senseId));

    await fetch(this.urlValue, {
      body,
      headers: {"X-CSRF-Token": token},
      method: "POST",
    });
  }
}
