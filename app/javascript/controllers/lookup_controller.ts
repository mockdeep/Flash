import {Controller} from "@hotwired/stimulus";
import {findEl} from "helpers/find_el";
import {setWordState} from "helpers/word_state";

interface LookupEvent {
  currentTarget: HTMLElement;
  params: {senseId: number};
}

export default class extends Controller {
  static override values = {url: String};

  declare urlValue: string;

  async record(event: LookupEvent): Promise<void> {
    // A lookup counts as a miss, so the word shows as one straight away.
    setWordState(event.currentTarget, "missed");

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
