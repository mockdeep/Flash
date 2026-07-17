import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";
import {findEl} from "helpers/find_el";
import {matchAnswers} from "helpers/fuzzy_match";

const MOBILE_VIEWPORT = "(max-width: 768px)";

export default class extends Controller<HTMLElement> {
  static override targets = [
    "input",
    "results",
    "noMatches",
    "form",
    "answerInput",
    "possibleAnswerInput",
    "matchTemplate",
  ];

  static override values = {
    answers: Array,
  };

  declare inputTarget: HTMLInputElement;

  declare resultsTarget: HTMLElement;

  declare noMatchesTarget: HTMLElement;

  declare formTarget: HTMLFormElement;

  declare answerInputTarget: HTMLInputElement;

  declare possibleAnswerInputTarget: HTMLInputElement;

  declare matchTemplateTarget: HTMLTemplateElement;

  declare answersValue: string[];

  private currentMatches: string[] = [];

  private selectedIndex = 0;

  override connect(): void {
    this.anchorStudyFrame();
  }

  filter(): void {
    this.currentMatches =
      matchAnswers(this.answersValue, this.inputTarget.value);
    this.selectedIndex = 0;
    this.renderMatches();
  }

  moveDown(event: KeyboardEvent): void {
    this.moveSelection(event, 1);
  }

  moveUp(event: KeyboardEvent): void {
    this.moveSelection(event, -1);
  }

  submitSelected(event: KeyboardEvent): void {
    event.preventDefault();
    const answer = this.currentMatches[this.selectedIndex];
    if (answer === undefined) { return; }
    this.submitWith(answer);
  }

  select(event: {params: {answer: string}}): void {
    this.submitWith(event.params.answer);
  }

  /*
   * Keep the study frame pinned to the top of the screen on mobile so the
   * page doesn't jump when the on-screen keyboard opens for the input.
   */
  private anchorStudyFrame(): void {
    if (!window.matchMedia(MOBILE_VIEWPORT).matches) { return; }
    const frame = ensure(this.element.closest(".study-frame"));
    frame.scrollIntoView({behavior: "instant", block: "start"});
  }

  private moveSelection(event: KeyboardEvent, delta: number): void {
    event.preventDefault();
    if (this.currentMatches.length === 0) { return; }
    const last = this.currentMatches.length - 1;
    this.selectedIndex =
      Math.min(Math.max(this.selectedIndex + delta, 0), last);
    this.highlightSelected();
  }

  private submitWith(answer: string): void {
    this.answerInputTarget.value = answer;
    this.possibleAnswerInputTarget.value = answer;
    this.formTarget.requestSubmit();
  }

  private renderMatches(): void {
    this.resultsTarget.replaceChildren();
    const empty = this.inputTarget.value.trim().length === 0;
    this.noMatchesTarget.hidden = this.currentMatches.length > 0 || empty;

    this.currentMatches.forEach((answer) => {
      this.resultsTarget.appendChild(this.buildMatchItem(answer));
    });
    this.highlightSelected();
  }

  private buildMatchItem(answer: string): DocumentFragment {
    const item = document.importNode(this.matchTemplateTarget.content, true);
    const button = findEl(item, "button", ".answer-button");
    button.dataset.fuzzyFindAnswerParam = answer;
    findEl(item, "span", ".answer-text").textContent = answer;

    return item;
  }

  private highlightSelected(): void {
    const buttons = this.resultsTarget.
      querySelectorAll<HTMLButtonElement>(".answer-button");
    buttons.forEach((button, index) => {
      const selected = index === this.selectedIndex;
      button.classList.toggle("is-selected", selected);
      button.setAttribute("aria-selected", String(selected));
    });
  }
}
