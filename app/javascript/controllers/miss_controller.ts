import {Controller} from "@hotwired/stimulus";
import {findEl} from "helpers/find_el";
import {setSenseState} from "helpers/word_state";

interface MissEvent {
  currentTarget: HTMLElement;
  params: {senseId: number};
}

export default class extends Controller {
  static override values = {url: String};

  declare urlValue: string;

  // Only a new word records a view; after that it takes Restudy.
  async view(event: MissEvent): Promise<void> {
    const word = event.currentTarget;
    if (!word.classList.contains("reading-snippet__word--new")) { return; }

    await this.record(event.params.senseId);
  }

  async restudy(event: MissEvent): Promise<void> {
    await this.record(event.params.senseId);
  }

  // A miss shows on the word straight away.
  private async record(senseId: number): Promise<void> {
    setSenseState(senseId, "missed");

    const {content: token} = findEl(document, "meta", "[name='csrf-token']");
    const body = new FormData();
    body.append("sense_id", String(senseId));

    await fetch(this.urlValue, {
      body,
      headers: {"X-CSRF-Token": token},
      method: "POST",
    });
  }
}
