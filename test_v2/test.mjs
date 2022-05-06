import * as fs from "fs";
import * as path from "path";

await import("../output/init.mjs");

async function run() {
  const root = "./test_v2/";

  for (const d of fs.readdirSync(root, {withFileTypes: true})) {
    if (d.isDirectory() === false) {
      continue;
    }

    const folderName = d.name;
    const folder = root + folderName + path.sep;
    console.log("* " + folderName);
    const spec = fs.readFileSync(folder + "spec.json", "utf-8");
    const number = folderName.match(/test(\d+)/)[1];

    const input = new abap.types.Structure({
      clas_icf_serv: new abap.types.Character({length: 30}).set('zcl_icf_serv' + number),
      clas_icf_impl: new abap.types.Character({length: 30}).set('zcl_icf_impl' + number),
      clas_client:   new abap.types.Character({length: 30}).set('zcl_client' + number),
      intf:          new abap.types.Character({length: 30}).set('zif_interface' + number),
      json:          new abap.types.String().set(spec)},
    );
    const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({is_input: input});

    fs.writeFileSync(folder + input.get().clas_icf_serv.get() + ".clas.abap", result.get().clas_icf_serv.get());
    fs.writeFileSync(folder + input.get().clas_icf_impl.get() + ".clas.abap", result.get().clas_icf_impl.get());
    fs.writeFileSync(folder + input.get().clas_client.get() + ".clas.abap", result.get().clas_client.get());
    fs.writeFileSync(folder + input.get().intf.get() + ".intf.abap", result.get().intf.get());

    const consoleOutput = abap.console.get();
    if (consoleOutput !== "") {
      console.log(consoleOutput);
    }
  }
}

console.log("V2 testing");
await run();