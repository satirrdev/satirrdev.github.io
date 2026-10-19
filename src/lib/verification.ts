/**
 * Entry verification gate.
 *
 * Layout.astro boots the gate in the document head, before the body paints.
 * Data fetches on every page call `waitForVerification()` first so nothing
 * loads until the short check finishes.
 */

interface GateWindow extends Window {
  __satirrGateVerified?: boolean;
  __satirrGateReady?: Promise<void>;
}

export function isVerified(): boolean {
  return Boolean((window as GateWindow).__satirrGateVerified);
}

export function waitForVerification(): Promise<void> {
  const w = window as GateWindow;
  if (w.__satirrGateVerified) return Promise.resolve();
  if (w.__satirrGateReady) return w.__satirrGateReady;
  return Promise.resolve();
}
