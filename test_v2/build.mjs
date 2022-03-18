import * as fs from "fs";

await import("../output/init.mjs");

async function run() {
  const folder = "./test_v2/test001/";
  const spec = fs.readFileSync(folder + "spec.json", "utf-8");

  const input = new abap.types.Structure({
    class_name:     new abap.types.Character({length: 30}).set('zcl_output'),
    interface_name: new abap.types.Character({length: 30}).set('zif_output'),
    json:           new abap.types.String().set(spec)}
  );
  const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({is_input: input});

  console.log(abap.console.get());

  fs.writeFileSync(folder + input.get().class_name.get() + ".clas.abap", result.get().clas.get());
  fs.writeFileSync(folder + input.get().interface_name.get() + ".intf.abap", result.get().intf.get());
}

await run();