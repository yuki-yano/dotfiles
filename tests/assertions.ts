import nodeAssert from "node:assert/strict";

export const assert: typeof nodeAssert = nodeAssert;
export function assertEquals(actual: unknown, expected: unknown, message?: string): void {
  if (message === undefined) nodeAssert.deepStrictEqual(actual, expected);
  else nodeAssert.deepStrictEqual(actual, expected, message);
}
export function assertFalse(value: unknown, message?: string): void {
  if (message === undefined) nodeAssert(value === false);
  else nodeAssert(value === false, message);
}
export function assertStringIncludes(value: string, expected: string): void {
  nodeAssert(value.includes(expected), `${JSON.stringify(value)} should include ${JSON.stringify(expected)}`);
}

export async function assertRejects<T extends Error>(
  operation: () => Promise<unknown>,
  errorType: new (...args: never[]) => T,
  message?: string,
): Promise<T> {
  try {
    await operation();
  } catch (error) {
    assert(error instanceof errorType);
    if (message) assertStringIncludes(error.message, message);
    return error;
  }
  assert.fail("Expected operation to reject");
}
