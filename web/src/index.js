// @ts-ignore
global.MonacoEnvironment = {
  globalAPI: true,
  getWorkerUrl: function(_moduleId, label) {
    if (label === "typescript" || label === "javascript") {
      return "./ts.worker.bundle.js";
    } else if (label === "json") {
      return "./json.worker.bundle.js";
    }
    return "./editor.worker.bundle.js";
  },
};

import "./index.css";
const monaco = require("monaco-editor"); // make sure this import is not hoisted
import * as abaplint from "@abaplint/core";
import * as abapMonaco from "@abaplint/monaco";
import Split from "split-grid";

import "../../output/_init.mjs";

const spec = `{
  "openapi": "3.0.2",
  "info": {
    "title": "title",
    "description": "description",
    "version": "1.0.0"
  },
  "paths": {
    "/zen": {
      "get": {
        "summary": "Get",
        "operationId": "get",
        "responses": {
          "200": {
            "description": "response",
            "content": {
              "text/plain": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    }
  }
}`;

const reg = new abaplint.Registry();
abapMonaco.registerABAP(reg);

const filename = "file:///spec.json";
const model1 = monaco.editor.createModel(
  spec,
  "json",
  monaco.Uri.parse(filename),
);

Split({
  columnGutters: [
    {
      track: 1,
      element: document.getElementById("gutter1"),
    },
    {
      track: 3,
      element: document.getElementById("gutter2"),
    },
  ],
});

const editor1 = monaco.editor.create(document.getElementById("container1"), {
  model: model1,
  theme: "vs-dark",
  minimap: {
    enabled: false,
  },
});

const editor2 = monaco.editor.create(document.getElementById("container2"), {
  value: "intf",
  theme: "vs-dark",
  minimap: {
    enabled: false,
  },
  readOnly: true,
  language: "abap",
});

const editor3 = monaco.editor.create(document.getElementById("container3"), {
  value: "clas",
  theme: "vs-dark",
  minimap: {
    enabled: false,
  },
  readOnly: true,
  language: "abap",
});

function updateEditorLayouts() {
  editor1.layout();
  editor2.layout();
  editor3.layout();
}

const observer = new MutationObserver(mutations => {
  for (const mutation of mutations) {
    if (mutation.attributeName === "style") {
      updateEditorLayouts();
    }
  }
});

observer.observe(document.getElementById("horizon"), {
  attributes: true,
  attributeFilter: [
    "style",
  ],
});

window.addEventListener("resize", updateEditorLayouts);

async function jsonChanged() {
  const main = new abap.Classes["ZCL_OAPI_MAIN"]();
  await main.constructor_();

  const input = new abap.types.Structure({
    class_name: new abap.types.Character({length: 30}),
    interface_name: new abap.types.Character({length: 30}),
    json: new abap.types.String()}
  );
  input.get().json.set(editor1.getValue());
  input.get().class_name.set('zcl_foobar');
  input.get().interface_name.set('zif_foobar');
  try {
    const result = await main.run({is_input: input});
    editor2.setValue(result.get().intf.get());
    editor3.setValue(result.get().clas.get());
  } catch (error) {
    editor2.setValue("");
    editor3.setValue(error.message);
    console.dir(error);
  }
}

editor1.onDidChangeModelContent(jsonChanged);
jsonChanged();
editor1.focus();