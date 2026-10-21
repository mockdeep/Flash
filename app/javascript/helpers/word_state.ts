const WORD = "reading-snippet__word";
const LOOKUP = "reading-snippet__lookup";
const STATES = ["new", "missed", "done"];

// Marks a Read-tab word with its state, or with none while it is part way.
function setWordState(word: Element, state: string | null): void {
  const classes = STATES.map((name) => { return `${WORD}--${name}`; });
  word.classList.remove(...classes);
  if (state !== null) { word.classList.add(`${WORD}--${state}`); }
}

// Marks every copy of a sense's word on the Read tab, and its popovers.
function setSenseState(senseId: number | string, state: string | null): void {
  const sense = `[data-sense-id="${senseId}"]`;
  document.querySelectorAll(`.${WORD}${sense}`).forEach((word) => {
    setWordState(word, state);
  });
  // A popover offers to restudy its word only while the word is done.
  document.querySelectorAll(`.${LOOKUP}${sense}`).forEach((lookup) => {
    lookup.classList.toggle(`${LOOKUP}--done`, state === "done");
  });
}

export {setSenseState};
