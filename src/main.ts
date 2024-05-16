import "glint-environment-gxt";
import "decorator-transforms/globals";
import "./style.css";

import { renderComponent, type ComponentReturnType } from "@lifeart/gxt";
// @ts-ignore unknown module import
import App from "./App.gts";

if (import.meta.env.DEV) {
  // @ts-ignore wrong dts
  await import('@lifeart/gxt/ember-inspector');
}

renderComponent(
  new App({}) as unknown as ComponentReturnType,
  document.getElementById("app")!
);
