# Code2Prompt

This is a simple web application that allows you to generate a prompt for a large language model (LLM) based on the contents of a GitHub repository.

## Usage

1. Enter your GitHub personal access token. This is required to access private repositories.
2. Enter the URL of the GitHub repository you want to use.

The application will then fetch the contents of the repository and generate a prompt that you can use with an LLM.

## Example

**Input:**

* GitHub URL: https://github.com/lifeart/glimmerx-workshop/tree/master

**Output:**

```
I have a GitHub repository with the following file structure:
```

```html
<DIRECTORY_TREE>
readme.md
[public/]
    favicon.ico
[src/]
    App.gts
</DIRECTORY_TREE>
```

```
Here are the contents of each file:
```

```hbs
<FILE path="index.html"><!doctype html>
<html lang="en">
  <head>
    <title>Code2Prompt</title>
    <link rel="manifest" href="./site.webmanifest" />
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="./src/main.ts"></script>
  </body>
</html>
</FILE>

```

## Development

### Prerequisites

* Node.js
* pnpm

### Installation

```
pnpm install
```

### Development Server

```
pnpm dev
```

### Building

```
pnpm build
```

### Testing

```
pnpm test
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT
