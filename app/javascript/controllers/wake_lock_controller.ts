import {Controller} from "@hotwired/stimulus";

async function requestLock(): Promise<WakeLockSentinel | null> {
  try {
    return await navigator.wakeLock.request("screen");
  } catch {
    return null;
  }
}

export default class extends Controller<HTMLElement> {
  private lockPromise!: Promise<WakeLockSentinel | null>;

  override connect(): void {
    this.lockPromise = requestLock();
  }

  override disconnect(): void {
    void this.lockPromise.then(async (lock) => {
      await lock?.release();
    });
  }

  /*
   * The browser drops the lock whenever the page is hidden, so it has to be
   * re-requested when the page comes back; bound to visibilitychange@document.
   */
  refresh(): void {
    if (!document.hidden) {
      this.lockPromise = requestLock();
    }
  }
}
