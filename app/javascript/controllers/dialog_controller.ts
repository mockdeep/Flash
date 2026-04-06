import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static override targets = ["dialog"];

  dialogTarget!: HTMLDialogElement;

  open(): void {
    this.dialogTarget.showModal();
  }

  close(): void {
    this.dialogTarget.close();
  }

  closeOnBackdropClick(event: MouseEvent): void {
    if (event.target === this.dialogTarget) {
      this.dialogTarget.close();
    }
  }

  closeOnSuccess(event: CustomEvent<{success: boolean}>): void {
    if (event.detail.success) {
      this.dialogTarget.close();
    }
  }
}
