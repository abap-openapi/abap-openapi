import * as https from "https";
import * as fs from "fs";
import * as path from "path";

await import("../output/init.mjs");

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
  const name = process.argv[3];

  const spec = url.startsWith("http")
    ? await get(url)
    : fs.readFileSync(url).toString();

  const input = new abap.types.Structure({
    clas_icf_serv: new abap.types.Character(30).set(`zcl_${name}_icf_serv`),
    clas_icf_impl: new abap.types.Character(30).set(`zcl_${name}_icf_impl`),
    clas_client: new abap.types.Character(30).set(`zcl_${name}_client`),
    intf: new abap.types.Character(30).set(`zif_${name}_interface`),
    openapi_json: new abap.types.String().set(spec),
  });
  const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({
    is_input: input,
  });

  fs.writeFileSync(
    folder + input.get().clas_icf_serv.get() + ".clas.abap",
    result.get().clas_icf_serv.get()
  );
  fs.writeFileSync(
    folder + input.get().clas_icf_impl.get() + ".clas.abap",
    result.get().clas_icf_impl.get()
  );
  fs.writeFileSync(
    folder + input.get().clas_client.get() + ".clas.abap",
    result.get().clas_client.get()
  );
  fs.writeFileSync(
    folder + input.get().intf.get() + ".intf.abap",
    result.get().intf.get()
  );

  const consoleOutput = abap.console.get();
  if (consoleOutput !== "") {
    console.log(consoleOutput);
  }
}

run()
  .then()
  .catch((err) => {
    console.dir(err);
    process.exit(1);
  });
