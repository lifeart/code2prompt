export function tpl() {
    return `
    Here is list of files in the repository.
File name located in "PATH" property of <File> tag and  file content is enclosed in <FILE> tag.
Project directory tree is enclosed in <DIRECTORY_TREE> tag.
-------------------------------------------
{DIRECTORY_TREE}
-------------------------------------------
{FILES}
    `.trim();
}