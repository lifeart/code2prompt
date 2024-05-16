const storageKey = `code2propmpt`;

type StorageKey = 'token' | 'name';

export function read(key: StorageKey, defaultValue: string): string {
  const accessKey = `${storageKey}/${key}`;
  try {
    return localStorage.getItem(accessKey) ?? String(defaultValue);
  } catch {
    return defaultValue;
  }
}
export function write(key: StorageKey, rawValue: string | object) {
    const value = typeof rawValue === 'string' ? rawValue : JSON.stringify(rawValue);
  const accessKey = `${storageKey}/${key}`;
  try {
    localStorage.setItem(accessKey, value);
  } catch (e) {
    // OOPS
  }
}
export function remove(key: StorageKey) {
  
  const accessKey = `${storageKey}/${key}`;
  try {
    localStorage.removeItem(accessKey);
  } catch(e) {
    // OOPS
  }
  return;
}