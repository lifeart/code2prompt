export function tpl({
  excludeDirectoryListing,
}: {
  excludeDirectoryListing: boolean;
}) {
  return `
    Here is list of files in the repository.
File name located in "PATH" property of <File> tag and  file content is enclosed in <FILE> tag.
${
  !excludeDirectoryListing
    ? `Project directory tree is enclosed in <DIRECTORY_TREE> tag.
-------------------------------------------
{DIRECTORY_TREE}`
    : ''
}
-------------------------------------------
{FILES}
    `.trim();
}
