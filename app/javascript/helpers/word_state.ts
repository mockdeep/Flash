const WORD = "reading-snippet__word";
const STATES = ["new", "missed", "done"];

// Marks a Read-tab word with its state, or with none while it is part way.
function setWordState(word: Element, state: string | null): void {
  const classes = STATES.map((name) => { return `${WORD}--${name}`; });
  word.classList.remove(...classes);
  if (state !== null) { word.classList.add(`${WORD}--${state}`); }
}

// Marks every copy of a sense's word on the Read tab.
function setSenseState(senseId: number | string, state: string | null): void {
  const selector = `[data-lookup-sense-id-param="${senseId}"]`;
  document.querySelectorAll(selector).forEach((word) => {
    setWordState(word, state);
  });
}

export {setSenseState};
