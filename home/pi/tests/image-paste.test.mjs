import assert from "node:assert/strict";
import { mkdtempSync, rmdirSync, unlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import imagePaste from "../image-paste.ts";

const png = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/iO8AAAAASUVORK5CYII=",
  "base64",
);

function fixture(t, filename) {
  const directory = mkdtempSync(join(tmpdir(), "nix-config-image-paste-"));
  const imagePath = join(directory, filename);
  writeFileSync(imagePath, png);
  t.after(() => {
    unlinkSync(imagePath);
    rmdirSync(directory);
  });

  let handleInput;
  imagePaste({
    on(event, handler) {
      if (event === "input") handleInput = handler;
    },
  });

  return {
    imagePath,
    transform: (text) =>
      handleInput(
        { source: "interactive", text, images: [] },
        { cwd: directory, hasUI: false, model: { input: ["text", "image"] } },
      ),
  };
}

test("preserves indentation, tabs and edge whitespace when attaching a named image", async (t) => {
  const { imagePath, transform } = fixture(t, "code sample.png");
  const prompt =
    "  Compare this code:\n\nif ready:\n    if enabled:\n        run()\n\t\tkeep_tabs()\n\n" +
    'Image: "' + imagePath + '"  \n';

  const result = await transform(prompt);

  assert.equal(result.action, "transform");
  assert.equal(result.images.length, 1);
  assert.equal(result.text, prompt);
});

test("removes clipboard paths without changing surrounding prompt whitespace", async (t) => {
  const { imagePath, transform } = fixture(t, "pi-clipboard-12345678-1234-1234-1234-123456789abc.png");
  const prompt = " \tBefore  " + imagePath + "\n\nif ready:\n    if enabled:\n        run()\n\t\tfinish()\n  After  \n";

  const result = await transform(prompt);

  assert.equal(result.action, "transform");
  assert.equal(result.images.length, 1);
  assert.equal(result.text, " \tBefore  \n\nif ready:\n    if enabled:\n        run()\n\t\tfinish()\n  After  \n");
});

test("provides nonempty text when only a clipboard attachment and whitespace remain", async (t) => {
  const { imagePath, transform } = fixture(t, "pi-clipboard-12345678-1234-1234-1234-123456789abc.png");

  const result = await transform("\t " + imagePath + " \n");

  assert.equal(result.action, "transform");
  assert.equal(result.images.length, 1);
  assert.notEqual(result.text.trim(), "");
  assert.equal(result.text.includes(imagePath), false);
});
