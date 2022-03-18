import * as fs from "fs";

await import("../output/init.mjs");

async function run() {
  const folder = "./test_v2/test001/";
  const spec = fs.readFileSync(folder + "spec.json", "utf-8");

  const input = new abap.types.Structure({
    clas_icf_serv: new abap.types.Character({length: 30}).set('zcl_icf_serv'),
    clas_icf_impl: new abap.types.Character({length: 30}).set('zcl_icf_impl'),
    clas_client:   new abap.types.Character({length: 30}).set('zcl_client'),
    intf:          new abap.types.Character({length: 30}).set('zif_interface'),
    json:          new abap.types.String().set(spec)},
  );
  const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({is_input: input});

  console.log(abap.console.get());

  fs.writeFileSync(folder + input.get().clas_icf_serv.get() + ".clas.abap", result.get().clas_icf_serv.get());
  fs.writeFileSync(folder + input.get().clas_icf_impl.get() + ".clas.abap", result.get().clas_icf_impl.get());
  fs.writeFileSync(folder + input.get().clas_client.get() + ".clas.abap", result.get().clas_client.get());
  fs.writeFileSync(folder + input.get().intf.get() + ".intf.abap", result.get().intf.get());
}

await run();