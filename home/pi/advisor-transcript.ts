export interface Section {
  isToolResult: boolean;
  text: string;
}

/** Middle-elide to an exact maximum, keeping the signal-rich head and tail. */
export function elide(text: string, max: number): string {
  const limit = Math.max(0, Math.floor(max));
  if (text.length <= limit) return text;

  const marker = "\n… [elided] …\n";
  if (limit <= marker.length) return text.slice(0, limit);

  const kept = limit - marker.length;
  const head = Math.floor(kept * 0.7);
  const tail = kept - head;
  return `${text.slice(0, head)}${marker}${text.slice(-tail)}`;
}

function totalChars(sections: Section[]): number {
  return sections.reduce((sum, section) => sum + section.text.length + 2, 0);
}

/**
 * Fit the transcript to budget by degrading the least valuable material first:
 * oldest tool results get stubbed out, and only if that is not enough do whole
 * sections drop off the front. The most recent exchanges always survive — they
 * are the ones the advice is actually about.
 */
export function fitToBudget(sections: Section[], budget: number): Section[] {
  const limit = Math.max(0, Math.floor(budget));
  if (!Number.isFinite(budget) || limit <= 2) return [];

  const result = [...sections];

  for (let i = 0; i < result.length && totalChars(result) > limit; i++) {
    const section = result[i];
    if (!section.isToolResult) continue;
    const firstLine = section.text.split("\n", 1)[0];
    result[i] = { ...section, text: `${firstLine}\n[older tool result elided to fit context]` };
  }

  while (result.length > 1 && totalChars(result) > limit) {
    result.shift();
  }

  if (result.length === 1 && totalChars(result) > limit) {
    result[0] = { ...result[0], text: elide(result[0].text, limit - 2) };
  }

  return result;
}
