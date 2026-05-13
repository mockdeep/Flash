import {Controller} from "@hotwired/stimulus";

const MAX_RESULTS = 5;

interface Match {
  answer: string;
  remaining: number;
}

function normalize(text: string): string {
  return text.
    normalize("NFD").
    replace(/\p{Diacritic}/gu, "").
    toLowerCase();
}

function remainingAt(
  answerWords: string[],
  queryWords: string[],
  start: number,
): number | null {
  let remaining = 0;
  for (const [offset, queryWord] of queryWords.entries()) {
    const word = answerWords[start + offset];
    if (word === undefined) { return null; }
    if (!word.startsWith(queryWord)) { return null; }
    remaining += word.length - queryWord.length;
  }

  return remaining;
}

function findPrefixMatch(
  answerWords: string[],
  queryWords: string[],
): number | null {
  for (let start = 0; start < answerWords.length; start += 1) {
    const remaining = remainingAt(answerWords, queryWords, start);
    if (remaining !== null) { return remaining; }
  }

  return null;
}

function tryMatch(answer: string, queryWords: string[]): Match | null {
  const answerWords = normalize(answer).split(/\s+/u);
  const remaining = findPrefixMatch(answerWords, queryWords);
  if (remaining === null) { return null; }

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

  filter(): void {
    const matches = matchAnswers(this.answersValue, this.inputTarget.value);
    this.currentMatches = matches.map((match) => {
      return match.answer;
    });
    this.renderMatches();
  }

  submitTop(event: KeyboardEvent): void {
    event.preventDefault();
    const top = this.currentMatches[0];
    if (top === undefined) { return; }
    this.submitWith(top);
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
