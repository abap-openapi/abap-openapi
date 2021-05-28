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
import {ABAP} from "@abaplint/runtime";
import * as abapMonaco from "@abaplint/monaco";
import Split from "split-grid";

global.abap = new ABAP();
// LOAD THE ABAP PARTS, NOTE THIS WILL BREAK SOMETIME
// there will be a some kind of load setup in the transpiler sometime, somehow
await import("../../output/cl_abap_char_utilities.clas.mjs");
await import("../../output/cl_abap_codepage.clas.mjs");
await import("../../output/cl_abap_conv_in_ce.clas.mjs");
await import("../../output/cl_abap_conv_out_ce.clas.mjs");
await import("../../output/cl_abap_format.clas.mjs");
await import("../../output/cl_abap_gzip.clas.mjs");
await import("../../output/cl_abap_hmac.clas.mjs");
await import("../../output/cl_abap_matcher.clas.mjs");
await import("../../output/cl_abap_math.clas.mjs");
await import("../../output/cl_abap_random.clas.mjs");
await import("../../output/cl_abap_refdescr.clas.mjs");
await import("../../output/cl_abap_regex.clas.mjs");
await import("../../output/cl_abap_structdescr.clas.mjs");
await import("../../output/cl_abap_tabledescr.clas.mjs");
await import("../../output/cl_abap_tstmp.clas.mjs");
await import("../../output/cl_abap_typedescr.clas.mjs");
await import("../../output/cl_abap_unit_assert.clas.mjs");
await import("../../output/cl_abap_zip.clas.mjs");
await import("../../output/cl_gdt_conversion.clas.mjs");
await import("../../output/cl_gui_cfw.clas.mjs");
await import("../../output/cl_gui_container.clas.mjs");
await import("../../output/cl_gui_frontend_services.clas.mjs");
await import("../../output/cl_http_client.clas.mjs");
await import("../../output/cl_http_utility.clas.mjs");
await import("../../output/cl_ixml.clas.mjs");
await import("../../output/cl_sxml_string_reader.clas.mjs");
await import("../../output/cl_system_uuid.clas.mjs");
await import("../../output/cx_abap_message_digest.clas.mjs");
await import("../../output/cx_dynamic_check.clas.mjs");
await import("../../output/cx_parameter_invalid_range.clas.mjs");
await import("../../output/cx_parameter_invalid_type.clas.mjs");
await import("../../output/cx_root.clas.mjs");
await import("../../output/cx_static_check.clas.mjs");
await import("../../output/cx_sxml_error.clas.mjs");
await import("../../output/cx_sy_codepage_converter_init.clas.mjs");
await import("../../output/cx_sy_conversion_codepage.clas.mjs");
await import("../../output/cx_sy_conversion_no_number.clas.mjs");
await import("../../output/cx_sy_create_data_error.clas.mjs");
await import("../../output/cx_sy_create_object_error.clas.mjs");
await import("../../output/cx_sy_dyn_call_error.clas.mjs");
await import("../../output/cx_sy_dyn_call_illegal_class.clas.mjs");
await import("../../output/cx_sy_dyn_call_illegal_method.clas.mjs");
await import("../../output/cx_sy_move_cast_error.clas.mjs");
await import("../../output/cx_sy_ref_is_initial.clas.mjs");
await import("../../output/if_http_client.intf.mjs");
await import("../../output/if_http_request.intf.mjs");
await import("../../output/if_http_response.intf.mjs");
await import("../../output/if_ixml.intf.mjs");
await import("../../output/if_ixml_attribute.intf.mjs");
await import("../../output/if_ixml_document.intf.mjs");
await import("../../output/if_ixml_element.intf.mjs");
await import("../../output/if_ixml_istream.intf.mjs");
await import("../../output/if_ixml_named_node_map.intf.mjs");
await import("../../output/if_ixml_node.intf.mjs");
await import("../../output/if_ixml_node_iterator.intf.mjs");
await import("../../output/if_ixml_node_list.intf.mjs");
await import("../../output/if_ixml_ostream.intf.mjs");
await import("../../output/if_ixml_parser.intf.mjs");
await import("../../output/if_ixml_renderer.intf.mjs");
await import("../../output/if_ixml_stream_factory.intf.mjs");
await import("../../output/if_message.intf.mjs");
await import("../../output/if_sxml_attribute.intf.mjs");
await import("../../output/if_sxml_close_element.intf.mjs");
await import("../../output/if_sxml_node.intf.mjs");
await import("../../output/if_sxml_open_element.intf.mjs");
await import("../../output/if_sxml_reader.intf.mjs");
await import("../../output/if_sxml_value.intf.mjs");
await import("../../output/if_sxml_value_node.intf.mjs");
await import("../../output/if_t100_message.intf.mjs");
await import("../../output/openabap.fugr.convert_itf_to_stream_text.mjs");
await import("../../output/openabap.fugr.docu_get.mjs");
await import("../../output/openabap.fugr.system_callstack.mjs");
await import("../../output/openabap.fugr.text_split.mjs");
await import("../../output/zcl_oapi_abap_name.clas.mjs");
await import("../../output/zcl_oapi_json.clas.mjs");
await import("../../output/zcl_oapi_main.clas.mjs");
await import("../../output/zcl_oapi_parser.clas.mjs");
await import("../../output/zcl_oapi_references.clas.mjs");
await import("../../output/zcl_oapi_schema.clas.mjs");
await import("../../output/zif_oapi_schema.intf.mjs");
await import("../../output/zif_oapi_specification_v3.intf.mjs");

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