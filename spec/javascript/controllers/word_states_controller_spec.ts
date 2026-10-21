import {describe, expect, it} from "vitest";
import {bootStimulus} from "support/stimulus";
import WordStatesController from "controllers/word_states_controller";

const WORD = "reading-snippet__word";

function buildWord(senseId: string, state: string): HTMLButtonElement {
  const word = document.createElement("button");
  word.setAttribute("data-sense-id", senseId);
  word.className = `${WORD} ${WORD}--${state}`;
  return word;
}

interface States {[senseId: string]: string | null}

async function sendStates(states: States): Promise<HTMLButtonElement[]> {
  const words = [buildWord("7", "new"), buildWord("7", "new")];
  words.push(buildWord("8", "done"));
  const sender = document.createElement("div");
  sender.setAttribute("data-controller", "word-states");
  sender.setAttribute("data-word-states-states-value", JSON.stringify(states));
  document.body.replaceChildren(...words, sender);
  await bootStimulus("word-states", WordStatesController);
  return words;
}

function classesOf(word: HTMLButtonElement | undefined): string[] {
  return [...word?.classList ?? []];
}


describe("connect", () => {
  it("marks every copy of a word with its state", async () => {
    const words = await sendStates({7: "missed"});

    expect(words.slice(0, 2).map(classesOf)).toStrictEqual([
      [WORD, `${WORD}--missed`],
      [WORD, `${WORD}--missed`],
    ]);
  });

  it("clears the state of a word part way there", async () => {
    const words = await sendStates({8: null});

    expect(classesOf(words[2])).toStrictEqual([WORD]);
  });

  it("leaves words it has no state for", async () => {
    const words = await sendStates({8: null});

    expect(classesOf(words[0])).toStrictEqual([WORD, `${WORD}--new`]);
  });
});

const LOOKUP = "reading-snippet__lookup";

async function sendLookupState(
  classes: string,
  state: string,
): Promise<string[]> {
  const lookup = document.createElement("div");
  lookup.setAttribute("data-sense-id", "7");
  lookup.className = classes;
  const sender = document.createElement("div");
  sender.setAttribute("data-controller", "word-states");
  sender.setAttribute("data-word-states-states-value", `{"7": "${state}"}`);
  document.body.replaceChildren(lookup, sender);
  await bootStimulus("word-states", WordStatesController);
  return [...lookup.classList];
}

describe("connect marks a word's popover", () => {
  it("as done when the word is done", async () => {
    const classes = await sendLookupState(LOOKUP, "done");

    expect(classes).toStrictEqual([LOOKUP, `${LOOKUP}--done`]);
  });

  it("as not done otherwise", async () => {
    const done = `${LOOKUP} ${LOOKUP}--done`;
    const classes = await sendLookupState(done, "missed");

    expect(classes).toStrictEqual([LOOKUP]);
  });
});
