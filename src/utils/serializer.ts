export function toFile(fileName: string, fileContent: string): string {
  return `
<FILE path="${fileName}">
${fileContent}
</FILE>
  `.trimEnd();
}