import "./index.css";
import * as monaco from "monaco-editor";
import * as abaplint from "@abaplint/core";
import {ABAP} from "@abaplint/runtime";
import * as abapMonaco from "@abaplint/monaco";
import Split from "split-grid";

// @ts-ignore
self.MonacoEnvironment = {
  getWorkerUrl: function(_moduleId, label) {
    if (label === "typescript" || label === "javascript") {
      return "./ts.worker.bundle.js";
    }
    return "./editor.worker.bundle.js";
  },
};

const reg = new abaplint.Registry();
abapMonaco.registerABAP(reg);

const filename = "file:///spec.json";
const model1 = monaco.editor.createModel(
  `{"hello": "world"}`,
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

// see https://github.com/SimulatedGREG/electron-vue/issues/777
// see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AsyncFunction
const AsyncFunction = new Function(`return Object.getPrototypeOf(async function(){}).constructor`)();

async function jsonChanged() {
  console.dir("run, todo");
}

editor1.onDidChangeModelContent(jsonChanged);
jsonChanged();
editor1.focus();
const abap = new ABAP();