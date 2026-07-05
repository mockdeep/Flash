import {Controller} from "@hotwired/stimulus";

const MAX_RESULTS = 5;

const ATOMIC_LATIN_SUBSTITUTIONS = new Map<string, string>([
  ["æ", "ae"],
  ["đ", "d"],
  ["ð", "d"],
  ["ħ", "h"],
  ["ł", "l"],
  ["ø", "oe"],
  ["œ", "oe"],
  ["ß", "ss"],
  ["þ", "th"],
]);

interface Match {
  answer: string;
  remaining: number;
}

function normalize(text: string): string {
  let result = text.
    normalize("NFD").
    replace(/\p{Diacritic}/gu, "").
    toLowerCase();
  for (const [from, to] of ATOMIC_LATIN_SUBSTITUTIONS) {
    result = result.split(from).join(to);
  }

  return result;
}

function findPrefixWord(
  answerWords: string[],
  queryWord: string,
  start: number,
): number {
  for (let index = start; index < answerWords.length; index += 1) {
    if (answerWords[index]?.startsWith(queryWord) === true) { return index; }
  }

  return -1;
}

function hasPrefixMatch(
  answerWords: string[],
  queryWords: string[],
): boolean {
  let start = 0;
  for (const queryWord of queryWords) {
    const index = findPrefixWord(answerWords, queryWord, start);
    if (index === -1) { return false; }
    start = index + 1;
  }

  return true;
}

function totalChars(words: string[]): number {
  return words.reduce((sum, word) => {
    return sum + word.length;
  }, 0);
}

function tryMatch(answer: string, queryWords: string[]): Match | null {
  const answerWords = normalize(answer).split(/\s+/u);
  if (!hasPrefixMatch(answerWords, queryWords)) { return null; }
  const remaining = totalChars(answerWords) - totalChars(queryWords);

  return {answer, remaining};
}

function collectMatches(answers: string[], queryWords: string[]): Match[] {
  const matches: Match[] = [];
  for (const answer of answers) {
    const match = tryMatch(answer, queryWords);
    if (match !== null) { matches.push(match); }
  }

  return matches;
}

function matchAnswers(answers: string[], rawQuery: string): Match[] {
  const query = normalize(rawQuery.trim());
  if (query.length === 0) { return []; }
  const queryWords = query.split(/\s+/u);
  const matches = collectMatches(answers, queryWords);
  matches.sort((left, right) => {
    return left.remaining - right.remaining;
  });

  return matches.slice(0, MAX_RESULTS);
}

export default class extends Controller<HTMLElement> {
  static override targets = [
    "input",
    "results",
    "noMatches",
    "form",
    "answerInput",
    "possibleAnswerInput",
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

  declare answersValue: string[];

  private currentMatches: string[] = [];

  private selectedIndex = 0;

  filter(): void {
    const matches = matchAnswers(this.answersValue, this.inputTarget.value);
    this.currentMatches = matches.map((match) => {
      return match.answer;
    });
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

  private highlightSelected(): void {
    const buttons = this.resultsTarget.
      querySelectorAll<HTMLButtonElement>(".answer-button");
    buttons.forEach((button, index) => {
      const selected = index === this.selectedIndex;
      button.classList.toggle("is-selected", selected);
      button.setAttribute("aria-selected", String(selected));
    });
  }

  private buildMatchItem(answer: string): HTMLLIElement {
    const li = document.createElement("li");
    li.appendChild(this.buildMatchButton(answer));

    return li;
  }

  private buildMatchButton(answer: string): HTMLButtonElement {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "answer-button";
    button.addEventListener("click", (event) => {
      event.preventDefault();
      this.submitWith(answer);
    });
    const text = document.createElement("span");
    text.className = "answer-text";
    text.textContent = answer;
    button.appendChild(text);

    return button;
  }
}
