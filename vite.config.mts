import { defineConfig } from "vite";
import { compiler, stripGXTDebug } from "@lifeart/gxt/compiler";
import babel from "vite-plugin-babel";

export default defineConfig(({ mode }) => ({
  plugins: [
    mode === "production"
      ? (babel({
          babelConfig: {
            babelrc: false,
            configFile: false,
            plugins: [stripGXTDebug],
          },
        }) as any)
      : null,
    compiler(mode),
  ],
  base: "",
  rollupOptions: {
    input: {
      main: "index.html",
      tests: "tests.html",
    },
  },
  resolve: {
    alias: [
      { find: /^@\/(.+)/, replacement: "/src/$1" },
    ],
  }
}));
