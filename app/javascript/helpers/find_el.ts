function findEl<T extends keyof HTMLElementTagNameMap>(
  root: ParentNode,
  tag: T,
  selector = "",
): HTMLElementTagNameMap[T] {
  const element = root.querySelector<HTMLElementTagNameMap[T]>(tag + selector);
  if (element === null) {
    throw new Error(`no element matching "${tag}${selector}"`);
  }

  return element;
}

export {findEl};
