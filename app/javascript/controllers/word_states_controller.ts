import {Controller} from "@hotwired/stimulus";
import {setWordState} from "helpers/word_state";

// Marks the Read tab's words with the states an answer sent along.
export default class extends Controller {
  static override values = {states: Object};

  declare statesValue: {[senseId: string]: string | null};

  override connect(): void {
    Object.entries(this.statesValue).forEach(([senseId, state]) => {
      const selector = `[data-lookup-sense-id-param="${senseId}"]`;
      document.querySelectorAll(selector).forEach((word) => {
        setWordState(word, state);
      });
    });
  }
}
