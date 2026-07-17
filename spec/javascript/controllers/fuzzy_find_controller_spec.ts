import {describe, expect, it, vi} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import FuzzyFindController from "controllers/fuzzy_find_controller";
import {ensure} from "helpers/ensure";
import {findEl} from "helpers/find_el";

const rootSel = "[data-controller='fuzzy-find']";
const inputSel = "[data-fuzzy-find-target='input']";
const resultsSel = "[data-fuzzy-find-target='results']";
const noMatchesSel = "[data-fuzzy-find-target='noMatches']";
const answerInputSel = "[data-fuzzy-find-target='answerInput']";
const possibleSel = "[data-fuzzy-find-target='possibleAnswerInput']";

type SubmitFn = (submitter?: HTMLElement | null) => void;

function rootEl(): HTMLElement {
  return findEl(document, "div", rootSel);
}

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
      <template data-fuzzy-find-target="matchTemplate">
        <li>
          <button
            type="button"
            class="answer-button"
            data-action="fuzzy-find#select"
          ><span class="answer-text"></span></button>
        </li>
      </template>
    </div>
  `;
  rootEl().dataset.fuzzyFindAnswersValue = JSON.stringify(answers);
}

async function boot(answers: string[]): Promise<FuzzyFindController> {
  setupDOM(answers);
  await bootStimulus("fuzzy-find", FuzzyFindController);

  return getController(rootEl(), "fuzzy-find", FuzzyFindController);
}

function inputEl(): HTMLInputElement {
  return findEl(document, "input", inputSel);
}

function resultsEl(): HTMLElement {
  return findEl(document, "ol", resultsSel);
}

function noMatchesEl(): HTMLElement {
  return findEl(document, "p", noMatchesSel);
}

function answerInputEl(): HTMLInputElement {
  return findEl(document, "input", answerInputSel);
}

function possibleAnswerInputEl(): HTMLInputElement {
  return findEl(document, "input", possibleSel);
}

function formEl(): HTMLFormElement {
  return findEl(document, "form");
}

function matchTexts(): string[] {
  return [...resultsEl().querySelectorAll("button")].map((button) => {
    return ensure(button.textContent);
  });
}

function stubSubmit(): SubmitFn {
  const stub = vi.fn<SubmitFn>();
  formEl().requestSubmit = stub;

  return stub;
}

function topMatchButton(): HTMLButtonElement {
  return findEl(resultsEl(), "button", ".answer-button");
}

async function typeAndFilter(
  controller: FuzzyFindController,
  value: string,
): Promise<void> {
  inputEl().value = value;
  controller.filter();
  await Promise.resolve();
}

function mockMobileViewport(): void {
  const matchMedia = window.matchMedia.bind(window);
  vi.spyOn(window, "matchMedia").mockImplementation((query) => {
    const mediaQueryList = matchMedia(query);
    Object.defineProperty(mediaQueryList, "matches", {value: true});

    return mediaQueryList;
  });
}

function wrapInStudyFrame(): HTMLElement {
  const frame = document.createElement("div");
  frame.className = "study-frame";
  frame.appendChild(rootEl());
  document.body.appendChild(frame);

  return frame;
}

describe("connect on a mobile viewport", () => {
  it("scrolls the study frame to the top of the screen", async () => {
    mockMobileViewport();
    setupDOM(["Paris"]);
    const frame = wrapInStudyFrame();
    const scroll = vi.fn<(options?: ScrollIntoViewOptions) => void>();
    frame.scrollIntoView = scroll;

    await bootStimulus("fuzzy-find", FuzzyFindController);

    expect(scroll).toHaveBeenCalledWith({behavior: "instant", block: "start"});
  });
});

describe("filter with no input", () => {
  it("shows nothing when input is empty", async () => {
    const controller = await boot(["Paris", "London"]);

    await typeAndFilter(controller, "");

    expect(matchTexts()).toStrictEqual([]);
    expect(noMatchesEl().hidden).toBe(true);
  });
});

describe("filter rendering", () => {
  it("renders the matching answers in ranked order", async () => {
    const controller = await boot(["caterpillar", "cat", "candy"]);

    await typeAndFilter(controller, "ca");

    expect(matchTexts()).toStrictEqual(["cat", "candy", "caterpillar"]);
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
      return ensure(button.textContent);
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
