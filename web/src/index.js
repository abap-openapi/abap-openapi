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
  columnGutters: [{
    track: 1,
    element: document.querySelector('.gutter-col-1'),
}, {
    track: 3,
    element: document.querySelector('.gutter-col-3'),
}, {
    track: 5,
    element: document.querySelector('.gutter-col-5'),
}, {
    track: 7,
    element: document.querySelector('.gutter-col-7'),
}],
});

const editor1 = monaco.editor.create(document.getElementById("container1"), {
  model: model1,
  theme: "vs-dark",
  minimap: {
    enabled: false,
  },
});

const readOnly = {
  theme: "vs-dark",
  minimap: {
    enabled: false,
  },
  readOnly: true,
  language: "abap",
};
const editor2 = monaco.editor.create(document.getElementById("container2"), readOnly);
const editor3 = monaco.editor.create(document.getElementById("container3"), readOnly);
const editor4 = monaco.editor.create(document.getElementById("container4"), readOnly);
const editor5 = monaco.editor.create(document.getElementById("container5"), readOnly);

function updateEditorLayouts() {
  editor1.layout();
  editor2.layout();
  editor3.layout();
  editor4.layout();
  editor5.layout();
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
  const input = new abap.types.Structure({
    clas_icf_serv: new abap.types.Character({length: 30}).set('zcl_icf_server'),
    clas_icf_impl: new abap.types.Character({length: 30}).set('zcl_icf_implementation'),
    clas_client: new abap.types.Character({length: 30}).set('zcl_client'),
    intf: new abap.types.Character({length: 30}).set('zif_interface'),
    openapi_json: new abap.types.String().set(editor1.getValue()),
  });

  try {
    const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({is_input: input});
    editor2.setValue(result.get().intf.get());
    editor3.setValue(result.get().clas_client.get());
    editor4.setValue(result.get().clas_icf_serv.get());
    editor5.setValue(result.get().clas_icf_impl.get());
  } catch (error) {
    editor2.setValue("");
    editor3.setValue(error.message);
    editor4.setValue("");
    editor5.setValue("");
    console.dir(error);
  }
}

editor1.onDidChangeModelContent(jsonChanged);
jsonChanged();
editor1.focus();