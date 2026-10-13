const WORD = "reading-snippet__word";
const STATES = ["new", "missed", "done"];

// Marks a Read-tab word with its state, or with none while it is part way.
function setWordState(word: Element, state: string | null): void {
  const classes = STATES.map((name) => { return `${WORD}--${name}`; });
  word.classList.remove(...classes);
  if (state !== null) { word.classList.add(`${WORD}--${state}`); }
}

export {setWordState};
