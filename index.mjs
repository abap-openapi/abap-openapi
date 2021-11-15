import * as https from "https";
import * as fs from "fs";
import * as path from "path";
import * as runtime from "@abaplint/runtime";
/*
const https = require("https");
const fs = require("fs");
const path = require("path");
const runtime = require("@abaplint/runtime");
*/
global.abap = new runtime.ABAP();
// LOAD THE ABAP PARTS, NOTE THIS WILL BREAK SOMETIME
// there will be a some kind of load setup in the transpiler sometime, somehow
await import("./output/cl_abap_char_utilities.clas.mjs");
await import("./output/cl_abap_codepage.clas.mjs");
await import("./output/cl_abap_conv_in_ce.clas.mjs");
await import("./output/cl_abap_conv_out_ce.clas.mjs");
await import("./output/cl_abap_format.clas.mjs");
await import("./output/cl_abap_gzip.clas.mjs");
await import("./output/cl_abap_hmac.clas.mjs");
await import("./output/cl_abap_matcher.clas.mjs");
await import("./output/cl_abap_math.clas.mjs");
await import("./output/cl_abap_random.clas.mjs");
await import("./output/cl_abap_refdescr.clas.mjs");
await import("./output/cl_abap_regex.clas.mjs");
await import("./output/cl_abap_structdescr.clas.mjs");
await import("./output/cl_abap_tabledescr.clas.mjs");
await import("./output/cl_abap_tstmp.clas.mjs");
await import("./output/cl_abap_typedescr.clas.mjs");
await import("./output/cl_abap_unit_assert.clas.mjs");
await import("./output/cl_abap_zip.clas.mjs");
await import("./output/cl_gdt_conversion.clas.mjs");
await import("./output/cl_gui_cfw.clas.mjs");
await import("./output/cl_gui_container.clas.mjs");
await import("./output/cl_gui_frontend_services.clas.mjs");
await import("./output/cl_http_client.clas.mjs");
await import("./output/cl_http_utility.clas.mjs");
await import("./output/cl_ixml.clas.mjs");
await import("./output/cl_sxml_string_reader.clas.mjs");
await import("./output/cl_system_uuid.clas.mjs");
await import("./output/cx_abap_message_digest.clas.mjs");
await import("./output/cx_dynamic_check.clas.mjs");
await import("./output/cx_parameter_invalid_range.clas.mjs");
await import("./output/cx_parameter_invalid_type.clas.mjs");
await import("./output/cx_root.clas.mjs");
await import("./output/cx_static_check.clas.mjs");
await import("./output/cx_sxml_error.clas.mjs");
await import("./output/cx_sy_codepage_converter_init.clas.mjs");
await import("./output/cx_sy_conversion_codepage.clas.mjs");
await import("./output/cx_sy_conversion_no_number.clas.mjs");
await import("./output/cx_sy_create_data_error.clas.mjs");
await import("./output/cx_sy_create_object_error.clas.mjs");
await import("./output/cx_sy_dyn_call_error.clas.mjs");
await import("./output/cx_sy_dyn_call_illegal_class.clas.mjs");
await import("./output/cx_sy_dyn_call_illegal_method.clas.mjs");
await import("./output/cx_sy_move_cast_error.clas.mjs");
await import("./output/cx_sy_ref_is_initial.clas.mjs");
await import("./output/if_http_client.intf.mjs");
await import("./output/if_http_request.intf.mjs");
await import("./output/if_http_response.intf.mjs");
await import("./output/if_ixml.intf.mjs");
await import("./output/if_ixml_attribute.intf.mjs");
await import("./output/if_ixml_document.intf.mjs");
await import("./output/if_ixml_element.intf.mjs");
await import("./output/if_ixml_istream.intf.mjs");
await import("./output/if_ixml_named_node_map.intf.mjs");
await import("./output/if_ixml_node.intf.mjs");
await import("./output/if_ixml_node_iterator.intf.mjs");
await import("./output/if_ixml_node_list.intf.mjs");
await import("./output/if_ixml_ostream.intf.mjs");
await import("./output/if_ixml_parser.intf.mjs");
await import("./output/if_ixml_renderer.intf.mjs");
await import("./output/if_ixml_stream_factory.intf.mjs");
await import("./output/if_message.intf.mjs");
await import("./output/if_sxml_attribute.intf.mjs");
await import("./output/if_sxml_close_element.intf.mjs");
await import("./output/if_sxml_node.intf.mjs");
await import("./output/if_sxml_open_element.intf.mjs");
await import("./output/if_sxml_reader.intf.mjs");
await import("./output/if_sxml_value.intf.mjs");
await import("./output/if_sxml_value_node.intf.mjs");
await import("./output/if_t100_message.intf.mjs");
await import("./output/openabap.fugr.convert_itf_to_stream_text.mjs");
await import("./output/openabap.fugr.docu_get.mjs");
await import("./output/openabap.fugr.system_callstack.mjs");
await import("./output/openabap.fugr.text_split.mjs");
await import("./output/zcl_oapi_abap_name.clas.mjs");
await import("./output/zcl_oapi_json.clas.mjs");
await import("./output/zcl_oapi_main.clas.mjs");
await import("./output/zcl_oapi_parser.clas.mjs");
await import("./output/zcl_oapi_references.clas.mjs");
await import("./output/zcl_oapi_schema.clas.mjs");
await import("./output/zif_oapi_schema.intf.mjs");
await import("./output/zif_oapi_specification_v3.intf.mjs");

async function get(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, (res) => {
      res.setEncoding("utf8");
      let responseBody = "";

      res.on("data", (chunk) => {
        responseBody += chunk;
      });

      res.on("end", () => {
        resolve(responseBody);
      });
    });

    req.on("error", (err) => {
      reject(err);
    });

    req.end();
  });
}

async function run() {
  const url = process.argv[2];
  if (url === undefined || url === "") {
    throw "supply url";
  } else if (process.argv[3] === undefined || process.argv[3] === "") {
    throw "supply name";
  }
  const spec = url.startsWith("http") ? await get(url) : fs.readFileSync(url).toString();

  const main = new abap.Classes["ZCL_OAPI_MAIN"]();
  await main.constructor_();

  const input = new abap.types.Structure({
    class_name: new abap.types.Character({length: 30}),
    interface_name: new abap.types.Character({length: 30}),
    json: new abap.types.String()}
  );
  input.get().json.set(spec);
  input.get().class_name.set('zcl_' + process.argv[3]);
  input.get().interface_name.set('zif_' + process.argv[3]);
  const result = await main.run({is_input: input});

  console.log(abap.console.get());

  const prefix = process.cwd() + path.sep + "test" + path.sep + "generated" + path.sep;
  if (fs.existsSync(prefix) === false) {
    fs.mkdirSync(prefix);
  }

  fs.writeFileSync(prefix + input.get().class_name.get() + ".clas.abap", result.get().clas.get());
  fs.writeFileSync(prefix + input.get().interface_name.get() + ".intf.abap", result.get().intf.get());
}

run().then().catch(err => {
  console.dir(err);
  process.exit(1);
});