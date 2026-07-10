import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = [
    "radio",
    "textInstructions",
    "musicInstructions",
    "musicSettings",
    "languageSettings",
  ];

  declare radioTargets: HTMLInputElement[];

  declare textInstructionsTarget: HTMLElement;

  declare musicInstructionsTarget: HTMLElement;

  declare musicSettingsTarget: HTMLFieldSetElement;

  declare languageSettingsTarget: HTMLFieldSetElement;

  override connect(): void {
    this.update();
  }

  update(): void {
    const checked = this.radioTargets.find((radio) => {
      return radio.checked;
    });
    const isMusic = checked?.value === "music";
    const isLanguage = checked?.value === "language";

    this.textInstructionsTarget.hidden = isMusic;
    this.musicInstructionsTarget.hidden = !isMusic;
    this.musicSettingsTarget.hidden = !isMusic;
    this.musicSettingsTarget.disabled = !isMusic;
    this.languageSettingsTarget.hidden = !isLanguage;
    this.languageSettingsTarget.disabled = !isLanguage;
  }
}
