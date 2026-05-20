const BADGES = {correct: "✓", incorrect: "✗"} as const;

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

export {BADGES, buildSpan, clearTimer};
