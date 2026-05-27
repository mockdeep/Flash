import {describe, expect, it, vi} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import FuzzyFindController from "controllers/fuzzy_find_controller";
import {assert} from "helpers/assert";

const rootSel = "[data-controller='fuzzy-find']";
const inputSel = "[data-fuzzy-find-target='input']";
const resultsSel = "[data-fuzzy-find-target='results']";
const noMatchesSel = "[data-fuzzy-find-target='noMatches']";
const answerInputSel = "[data-fuzzy-find-target='answerInput']";
const possibleSel = "[data-fuzzy-find-target='possibleAnswerInput']";
const matchButtonSel = "button.answer-button";

type SubmitFn = (submitter?: HTMLElement | null) => void;

function setupDOM(answers: string[]): void {
  document.body.innerHTML = `
    <div data-controller="fuzzy-find">
      <form data-fuzzy-find-target="form">
        <input type="hidden" data-fuzzy-find-target="answerInput">
        <input type="hidden" data-fuzzy-find-target="possibleAnswerInput">
      </form>
      <input type="text" data-fuzzy-find-target="input">
      <ol data-fuzzy-find-target="results"></ol>
      <p data-fuzzy-find-target="noMatches" hidden></p>
    </div>
  `;
  const root = assert(document.querySelector<HTMLElement>(rootSel));
  root.dataset.fuzzyFindAnswersValue = JSON.stringify(answers);
}

async function boot(answers: string[]): Promise<FuzzyFindController> {
  setupDOM(answers);
  await bootStimulus("fuzzy-find", FuzzyFindController);
  const root = assert(document.querySelector<HTMLElement>(rootSel));

  return getController(root, "fuzzy-find", FuzzyFindController);
}

function inputEl(): HTMLInputElement {
  return assert(document.querySelector<HTMLInputElement>(inputSel));
}

function resultsEl(): HTMLElement {
  return assert(document.querySelector<HTMLElement>(resultsSel));
}

function noMatchesEl(): HTMLElement {
  return assert(document.querySelector<HTMLElement>(noMatchesSel));
}

function answerInputEl(): HTMLInputElement {
  return assert(document.querySelector<HTMLInputElement>(answerInputSel));
}

function possibleAnswerInputEl(): HTMLInputElement {
  return assert(document.querySelector<HTMLInputElement>(possibleSel));
}

function formEl(): HTMLFormElement {
  return assert(document.querySelector<HTMLFormElement>("form"));
}

function matchTexts(): string[] {
  return [...resultsEl().querySelectorAll("button")].map((button) => {
    return assert(button.textContent);
  });
}

function stubSubmit(): SubmitFn {
  const stub = vi.fn<SubmitFn>();
  formEl().requestSubmit = stub;

  return stub;
}

function topMatchButton(): HTMLButtonElement {
  const button = resultsEl().querySelector<HTMLButtonElement>(matchButtonSel);

  return assert(button);
}

async function typeAndFilter(
  controller: FuzzyFindController,
  value: string,
): Promise<void> {
  inputEl().value = value;
  controller.filter();
  await Promise.resolve();
}

describe("filter with no input", () => {
  it("shows nothing when input is empty", async () => {
    const controller = await boot(["Paris", "London"]);

    await typeAndFilter(controller, "");

    expect(matchTexts()).toStrictEqual([]);
    expect(noMatchesEl().hidden).toBe(true);
  });
});

describe("filter matching", () => {
  it("shows matching answers when input has a prefix", async () => {
    const controller = await boot(["Paris", "London", "Berlin"]);

    await typeAndFilter(controller, "pa");

    expect(matchTexts()).toStrictEqual(["Paris"]);
  });

  it("orders matches by fewest remaining characters first", async () => {
    const controller = await boot(["caterpillar", "cat", "candy"]);

    await typeAndFilter(controller, "ca");

    expect(matchTexts()).toStrictEqual(["cat", "candy", "caterpillar"]);
  });

  it("counts unmatched words toward remaining characters", async () => {
    const controller = await boot([
      "to live in an apartment",
      "to live in a house",
      "to live",
    ]);

    await typeAndFilter(controller, "to live");

    expect(matchTexts()).toStrictEqual([
      "to live",
      "to live in a house",
      "to live in an apartment",
    ]);
  });

  it("matches against any word in a phrase", async () => {
    const controller = await boot(["the quick brown fox", "lazy dog"]);

    await typeAndFilter(controller, "qu");

    expect(matchTexts()).toStrictEqual(["the quick brown fox"]);
  });

  it("caps results at five entries", async () => {
    const answers = ["aa", "ab", "ac", "ad", "ae", "af", "ag"];
    const controller = await boot(answers);

    await typeAndFilter(controller, "a");

    expect(matchTexts()).toHaveLength(5);
  });
});

describe("filter multi-word matching", () => {
  it("matches consecutive words when the query has whitespace", async () => {
    const controller = await boot(["last name", "first name", "lastly"]);

    await typeAndFilter(controller, "last name");

    expect(matchTexts()).toStrictEqual(["last name"]);
  });

  it("matches consecutive word prefixes inside a phrase", async () => {
    const controller = await boot([
      "the quick brown fox",
      "quick fox",
      "brown bear",
    ]);

    await typeAndFilter(controller, "qu br");

    expect(matchTexts()).toStrictEqual(["the quick brown fox"]);
  });

  it("does not match when query words are out of order", async () => {
    const controller = await boot(["the quick brown fox"]);

    await typeAndFilter(controller, "br qu");

    expect(matchTexts()).toStrictEqual([]);
  });

  it("collapses internal whitespace when splitting the query", async () => {
    const controller = await boot(["last name"]);

    await typeAndFilter(controller, "last   name");

    expect(matchTexts()).toStrictEqual(["last name"]);
  });

  it("does not match when the answer is shorter than the query", async () => {
    const controller = await boot(["short"]);

    await typeAndFilter(controller, "short answer");

    expect(matchTexts()).toStrictEqual([]);
  });
});

describe("filter normalization", () => {
  it("matches case-insensitively", async () => {
    const controller = await boot(["Paris"]);

    await typeAndFilter(controller, "PAR");

    expect(matchTexts()).toStrictEqual(["Paris"]);
  });

  it("matches accent-insensitively", async () => {
    const controller = await boot(["café", "carrot"]);

    await typeAndFilter(controller, "caf");

    expect(matchTexts()).toStrictEqual(["café"]);
  });

  it("treats typed accents as base letters", async () => {
    const controller = await boot(["café"]);

    await typeAndFilter(controller, "café");

    expect(matchTexts()).toStrictEqual(["café"]);
  });
});

describe("filter atomic Latin substitution", () => {
  it.each([
    ["Straße", "strasse"],
    ["Þór", "thor"],
    ["nære", "naere"],
    ["øl", "oel"],
    ["sœur", "soeur"],
    ["eðli", "edli"],
    ["đak", "dak"],
    ["łódź", "lodz"],
    ["ħamiem", "hamiem"],
  ])("matches %s when typing %s", async (answer, input) => {
    const controller = await boot([answer]);
    await typeAndFilter(controller, input);

    expect(matchTexts()).toStrictEqual([answer]);
  });

  it.each([
    "Straße",
    "Þór",
    "nære",
    "øl",
    "sœur",
    "eðli",
    "đak",
    "łódź",
    "ħamiem",
  ])("matches %s when typing it directly", async (answer) => {
    const controller = await boot([answer]);
    await typeAndFilter(controller, answer);

    expect(matchTexts()).toStrictEqual([answer]);
  });
});

describe("filter no-matches state", () => {
  it("shows the no-matches message when nothing matches", async () => {
    const controller = await boot(["Paris"]);

    await typeAndFilter(controller, "xyz");

    expect(matchTexts()).toStrictEqual([]);
    expect(noMatchesEl().hidden).toBe(false);
  });

  it("hides the no-matches message when input clears", async () => {
    const controller = await boot(["Paris"]);
    await typeAndFilter(controller, "xyz");

    await typeAndFilter(controller, "");

    expect(noMatchesEl().hidden).toBe(true);
  });
});

describe("selectMatch", () => {
  it("submits the form with the clicked match", async () => {
    const controller = await boot(["Paris", "London"]);
    await typeAndFilter(controller, "p");
    const submit = stubSubmit();

    topMatchButton().click();

    expect(submit).toHaveBeenCalledWith();
    expect(answerInputEl().value).toBe("Paris");
  });
});

function keydown(key: string): KeyboardEvent {
  return new KeyboardEvent("keydown", {key});
}

describe("submitSelected", () => {
  it("submits the form with the top-ranked match by default", async () => {
    const controller = await boot(["caterpillar", "cat"]);
    await typeAndFilter(controller, "ca");
    const submit = stubSubmit();

    controller.submitSelected(keydown("Enter"));

    expect(submit).toHaveBeenCalledWith();
    expect(answerInputEl().value).toBe("cat");
  });

  it("does nothing when there are no matches", async () => {
    const controller = await boot(["Paris"]);
    await typeAndFilter(controller, "xyz");
    const submit = stubSubmit();

    controller.submitSelected(keydown("Enter"));

    expect(submit).not.toHaveBeenCalled();
  });

  it("populates possible_answers with the submitted answer", async () => {
    const controller = await boot(["Paris"]);
    await typeAndFilter(controller, "p");
    stubSubmit();

    controller.submitSelected(keydown("Enter"));

    expect(possibleAnswerInputEl().value).toBe("Paris");
  });
});

function selectedTexts(): string[] {
  return [...resultsEl().querySelectorAll(".answer-button.is-selected")].
    map((button) => {
      return assert(button.textContent);
    });
}

describe("arrow-key highlight movement", () => {
  it("highlights the top match by default", async () => {
    const controller = await boot(["cat", "candy", "caterpillar"]);

    await typeAndFilter(controller, "ca");

    expect(selectedTexts()).toStrictEqual(["cat"]);
  });

  it("moves the highlight down with the down arrow", async () => {
    const controller = await boot(["cat", "candy", "caterpillar"]);
    await typeAndFilter(controller, "ca");

    controller.moveDown(keydown("ArrowDown"));

    expect(selectedTexts()).toStrictEqual(["candy"]);
  });

  it("moves the highlight back up with the up arrow", async () => {
    const controller = await boot(["cat", "candy", "caterpillar"]);
    await typeAndFilter(controller, "ca");
    controller.moveDown(keydown("ArrowDown"));

    controller.moveUp(keydown("ArrowUp"));

    expect(selectedTexts()).toStrictEqual(["cat"]);
  });

  it("does nothing when there are no matches", async () => {
    const controller = await boot(["Paris"]);
    await typeAndFilter(controller, "xyz");

    controller.moveDown(keydown("ArrowDown"));

    expect(selectedTexts()).toStrictEqual([]);
  });
});

describe("arrow-key selection edges and submit", () => {
  it("clamps at the last match", async () => {
    const controller = await boot(["cat", "candy"]);
    await typeAndFilter(controller, "ca");

    controller.moveDown(keydown("ArrowDown"));
    controller.moveDown(keydown("ArrowDown"));

    expect(selectedTexts()).toStrictEqual(["candy"]);
  });

  it("clamps at the first match", async () => {
    const controller = await boot(["cat", "candy"]);
    await typeAndFilter(controller, "ca");

    controller.moveUp(keydown("ArrowUp"));

    expect(selectedTexts()).toStrictEqual(["cat"]);
  });

  it("submits the highlighted match on Enter", async () => {
    const controller = await boot(["cat", "candy", "caterpillar"]);
    await typeAndFilter(controller, "ca");
    controller.moveDown(keydown("ArrowDown"));
    const submit = stubSubmit();

    controller.submitSelected(keydown("Enter"));

    expect(submit).toHaveBeenCalledWith();
    expect(answerInputEl().value).toBe("candy");
  });

  it("resets the highlight to the top when the query changes", async () => {
    const controller = await boot(["cat", "candy", "caterpillar"]);
    await typeAndFilter(controller, "ca");
    controller.moveDown(keydown("ArrowDown"));

    await typeAndFilter(controller, "cat");

    expect(selectedTexts()).toStrictEqual(["cat"]);
  });
});
