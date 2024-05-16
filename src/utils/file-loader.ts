import { toFile } from './serializer';
import { tpl } from './tpl';

export async function loadFile(
  file: File,
  options: {
    dirsToSkip: string[];
    filesToSkip: string[];
    knownExtensions: string[];
  },
): Promise<string> {
  const { dirsToSkip, filesToSkip, knownExtensions } = options;
  const { unzip, strFromU8 } = await import('fflate');

  const filter = (file: { name: string }) => {
    const key = file.name;
    const isFolder = key.endsWith('/');
    const parts = key.split('/');
    const skip = dirsToSkip.some((folder) => parts.includes(folder));

    if (isFolder) {
      if (skip) return false;
    } else {
      if (skip) return false;
      const fileExt = key.split('.').pop();
      if (!fileExt || !knownExtensions.includes(`.${fileExt}`)) return false;
      const fileName = key.split('/').pop();
      if (!fileName || filesToSkip.includes(fileName.toLowerCase()))
        return false;
    }

    return true;
  };
  const result = (await new Promise(async (resolve, reject) => {
    unzip(
      new Uint8Array(await file.arrayBuffer()),
      {
        filter(file) {
          if (filter(file)) {
            // console.log('unzipped', file.name);
            return true;
          } else {
            // console.log('skipped', file.name);
            return false;
          }
        },
      },
      (err, data) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(data);
      },
    );
  })) as Record<string, Uint8Array>;
  const files: Record<string, string> = {};

  const fileWithContent: string[] = [];
  Object.keys(result).forEach((key) => {
    const isFolder = key.endsWith('/');
    if (isFolder) return;
    const file = result[key];
    files[key] = strFromU8(file);
    fileWithContent.push(toFile(key, files[key]));
  });
  let formattedString = tpl().replace(
    '{DIRECTORY_TREE}',
    Object.keys(files).join('\n'),
  );
  return formattedString.replace('{FILES}', fileWithContent.join('\n'));
}
