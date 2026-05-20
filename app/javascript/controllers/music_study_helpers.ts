import type {SessionState} from "music/sequence_session";

const BADGES = {correct: "✓", incorrect: "✗"} as const;

type AttemptKind = "correct" | "incorrect";

function buildSpan(className: string, text: string): HTMLSpanElement {
  const span = document.createElement("span");
  span.classList.add(className);
  span.textContent = text;

  return span;
}

function clearTimer(handle: ReturnType<typeof setTimeout> | null): null {
  if (handle !== null) {
    clearTimeout(handle);
  }

  return null;
}

function prependAttempt(
  parent: HTMLElement,
  note: string,
  kind: AttemptKind,
): void {
  const row = document.createElement("div");
  row.classList.add("answer-row", `answer-${kind}`, "music-study__attempt");
  row.appendChild(buildSpan("answer-number", BADGES[kind]));
  row.appendChild(buildSpan("music-study__attempt-text", note));
  parent.prepend(row);
}

function renderProgress(target: HTMLElement, state: SessionState): void {
  target.textContent = `${state.nextIndex} / ${state.notes.length}`;
}

function bindInactivity(
  onInactive: () => void,
  onActive: () => void,
): () => void {
  function handleVisibility(): void {
    if (document.hidden) {
      onInactive();
    } else {
      onActive();
    }
  }
  window.addEventListener("blur", onInactive);
  window.addEventListener("focus", onActive);
  document.addEventListener("visibilitychange", handleVisibility);

  return function unbind(): void {
    window.removeEventListener("blur", onInactive);
    window.removeEventListener("focus", onActive);
    document.removeEventListener("visibilitychange", handleVisibility);
  };
}

export {bindInactivity, clearTimer, prependAttempt, renderProgress};
