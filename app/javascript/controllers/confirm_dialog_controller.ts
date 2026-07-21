import {Controller} from "@hotwired/stimulus";

export default class extends Controller<HTMLFormElement> {
  static override targets = ["dialog"];

  declare dialogTarget: HTMLDialogElement;

  private confirmed = false;

  intercept(event: SubmitEvent): void {
    if (this.confirmed) {
      this.confirmed = false;
      return;
    }

    event.preventDefault();
    this.dialogTarget.showModal();
  }

  confirm(): void {
    this.dialogTarget.close();
    this.confirmed = true;
    this.element.requestSubmit();
  }

  close(): void {
    this.dialogTarget.close();
  }

  closeOnBackdropClick(event: MouseEvent): void {
    if (event.target === this.dialogTarget) {
      this.dialogTarget.close();
    }
  }
}
