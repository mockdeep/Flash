import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = [
    "radio",
    "textInstructions",
    "musicInstructions",
    "musicSettings",
  ];

  radioTargets!: HTMLInputElement[];

  textInstructionsTarget!: HTMLElement;

  musicInstructionsTarget!: HTMLElement;

  musicSettingsTarget!: HTMLFieldSetElement;

  override connect(): void {
    this.update();
  }

  update(): void {
    const isMusic = this.radioTargets.some((radio) => {
      return radio.checked && radio.value === "music";
    });

    this.textInstructionsTarget.hidden = isMusic;
    this.musicInstructionsTarget.hidden = !isMusic;
    this.musicSettingsTarget.hidden = !isMusic;
    this.musicSettingsTarget.disabled = !isMusic;
  }
}
