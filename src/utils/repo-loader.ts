// import { dirsToSkip, filesToSkip, knownExtensions } from "./constants";

interface GithubFileInfo {
  name: string;
  path: string;
  type: 'dir' | 'file';
  content: string;
  download_url: string;
  size: number;
  encoding: string;
}

interface GithubRepoInfo {
  owner: string;
  repo: string;
}

const parseGithubUrl = (url: string): GithubRepoInfo => {
  const parsedUrl = new URL(url);
  const pathSegments = parsedUrl.pathname.split('/').filter(Boolean);
  if (pathSegments.length >= 2) {
    return { owner: pathSegments[0], repo: pathSegments[1] };
  }
  throw new Error('Invalid GitHub URL provided!');
};

const fetchRepoContent = async (
  owner: string,
  repo: string,
  path = '',
  token?: string,
): Promise<GithubFileInfo[] | GithubFileInfo> => {
  const baseUrl = `https://api.github.com/repos/${owner}/${repo}/contents/${encodeURIComponent(path)}`;
  const headers: Record<string, string> = {
    Accept: 'application/vnd.github.v3+json',
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }
  try {
    const response = await fetch(baseUrl, { headers });
    if (!response.ok) {
      throw new Error(`Error fetching repository content: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    throw new Error(`Error fetching repository content: ${error}`);
  }
};

const getFileContent = (fileInfo: GithubFileInfo): string => {
  if (fileInfo.encoding === 'base64') {
    return atob(fileInfo.content);
  }
  return fileInfo.content;
};

const buildDirectoryTree = async (
  owner: string,
  repo: string,
  path = '',
  token = '',
  indent = 0,
  filePaths: Set<string> = new Set(),
  config: {
    dirsToSkip: string[];
    filesToSkip: string[];
    knownExtensions: string[];
    isAlive: () => boolean;
  },
): Promise<[string, Set<string>]> => {
  const items = await fetchRepoContent(owner, repo, path, token);
  if (!Array.isArray(items)) {
    throw new Error('Error fetching directory tree');
  }
  let treeStr = '';
  if (!config.isAlive()) {
    throw new Error('Process was terminated');
  }
  for (const item of items) {
    if (config.dirsToSkip.some((dir) => item.path.includes(dir))) {
      continue;
    }
    if (item.type === 'dir') {
      treeStr += '    '.repeat(indent) + `[${item.name}/]\n`;
      const [nestedTree] = await buildDirectoryTree(
        owner,
        repo,
        item.path,
        token,
        indent + 1,
        filePaths,
        config,
      );
      if (!config.isAlive()) {
        throw new Error('Process was terminated');
      }
      treeStr += nestedTree;
    } else {
      treeStr += '    '.repeat(indent) + `${item.name}\n`;
      const ext = `.${item.name.split('.').pop() ?? ''}`;
      if (
        config.knownExtensions.includes(ext!) &&
        !config.filesToSkip.includes(item.name.toLowerCase())
      ) {
        filePaths.add(item.path);
      }
    }
  }
  return [treeStr, filePaths];
};

export const retrieveGithubRepoInfo = async (
  url: string,
  token: string = '',
  config: {
    dirsToSkip: string[];
    filesToSkip: string[];
    knownExtensions: string[];
    isAlive: () => boolean;
  } = {
    dirsToSkip: [],
    filesToSkip: [],
    knownExtensions: [],
    isAlive: () => true,
  },
): Promise<string> => {
  const { owner, repo } = parseGithubUrl(url);

  let formattedString = '';

  //   try {
  //     const readmeInfo = await fetchRepoContent(owner, repo, 'README.md', token);
  //     if (Array.isArray(readmeInfo)) {
  //       throw new Error('Error fetching README');
  //     }
  //     const readmeContent = getFileContent(readmeInfo);
  //     // formattedString += `README.md:\n\n${readmeContent}\n\n\n`;
  //   } catch (error) {
  //     // formattedString += 'README.md: Not found or error fetching README\n\n';
  //   }

  const [directoryTree, filePaths] = await buildDirectoryTree(
    owner,
    repo,
    '',
    token,
    0,
    new Set(),
    config,
  );

  formattedString += `
    Here is list of files in the repository,
    File name is enclosed in <FILE_PATH> tag and content is enclosed in <FILE_CONTENT> tag
    -------------------------------------------
    Here is Directory tree:
    <DIRECTORY_TREE>
    ${directoryTree}
    </DIRECTORY_TREE>
    -------------------------------------------
  `;

  if (!config.isAlive()) {
    return 'Process was terminated';
  }

  for (const path of filePaths) {
    try {
      if (!config.isAlive()) {
        return 'Process was terminated';
      }
      const fileInfo = await fetchRepoContent(owner, repo, path, token);
      if (!config.isAlive()) {
        return 'Process was terminated';
      }
      if (Array.isArray(fileInfo)) {
        throw new Error('Error fetching file');
      }
      const fileContent = getFileContent(fileInfo);
      formattedString += `
    <FILE_PATH>${path}</FILE_PATH>
    <FILE_CONTENT>${fileContent}</FILE_CONTENT>
    `;
    } catch (error) {
      //
    }
  }

  return formattedString;
};
