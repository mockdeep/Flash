import {describe, expect, it} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import FileUploadController from "controllers/file_upload_controller";
import {ensure} from "helpers/ensure";

const iconSel = "[data-file-upload-target='icon']";
const textSel = "[data-file-upload-target='text']";

function setupDOM(): void {
  document.body.innerHTML = `
    <div data-controller="file-upload">
      <input
        type="file"
        data-file-upload-target="input"
        data-action="file-upload#select"
      />
      <div class="file-upload-label">
        <span data-file-upload-target="icon">📤</span>
        <span data-file-upload-target="text">Choose CSV file or drag here</span>
      </div>
    </div>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("file-upload", FileUploadController);
}

function element(): HTMLElement {
  const selector = "[data-controller='file-upload']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

function controller(): FileUploadController {
  return getController(element(), "file-upload", FileUploadController);
}

function icon(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(iconSel));
}

function text(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(textSel));
}

function fileList(files: File[]): FileList {
  const list = {
    item: (index: number): File | null => { return files[index] ?? null; },
    length: files.length,
    [Symbol.iterator]: (): ArrayIterator<File> => {
      return files[Symbol.iterator]();
    },
  } as FileList;

  for (const [index, file] of files.entries()) {
    Object.defineProperty(list, index, {value: file});
  }

  return list;
}

function setFiles(files: File[]): void {
  Object.defineProperty(controller().inputTarget, "files", {
    configurable: true,
    value: fileList(files),
  });
}

function csvFile(): File {
  return new File(["content"], "vocab.csv", {type: "text/csv"});
}

describe("select with a file", () => {
  it("shows the filename", async () => {
    await setupController();
    setFiles([csvFile()]);

    controller().select();

    expect(text().textContent).toBe("vocab.csv");
  });

  it("updates the icon to a checkmark", async () => {
    await setupController();
    setFiles([csvFile()]);

    controller().select();

    expect(icon().textContent).toBe("✅");
  });

  it("adds the file-selected class", async () => {
    await setupController();
    setFiles([csvFile()]);

    controller().select();

    expect(element().classList).toContain("file-selected");
  });
});

describe("select when cleared", () => {
  it("reverts the icon", async () => {
    await setupController();
    setFiles([csvFile()]);
    controller().select();

    setFiles([]);
    controller().select();

    expect(icon().textContent).toBe("📤");
  });

  it("reverts the text", async () => {
    await setupController();
    setFiles([csvFile()]);
    controller().select();

    setFiles([]);
    controller().select();

    expect(text().textContent).toBe("Choose CSV file or drag here");
  });

  it("removes the file-selected class", async () => {
    await setupController();
    setFiles([csvFile()]);
    controller().select();

    setFiles([]);
    controller().select();

    expect(element().classList).not.toContain("file-selected");
  });
});

describe("select when files is null", () => {
  it("reverts the icon", async () => {
    await setupController();
    Object.defineProperty(controller().inputTarget, "files", {
      configurable: true,
      value: null,
    });

    controller().select();

    expect(icon().textContent).toBe("📤");
  });
});
