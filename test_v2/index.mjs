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
    throw "supply a url or path to a file";
  } else if (process.argv[3] === undefined || process.argv[3] === "") {
    throw "supply a target folder name";
  }
  const folder = process.argv[3] + "/";
  let number = "";
  const constFolderMatch = folder.match(/test(\d+)/);
  if (constFolderMatch !== null) {
    number = constFolderMatch[1];
  }

  let name = "_";
  if (process.argv[4] !== undefined && process.argv[4] !== "") {
    name = name + process.argv[4] + "_";
  }

  const spec = url.startsWith("http")
    ? await get(url)
    : fs.readFileSync(url).toString();

  let clas_icf_serv = `zcl${name}icf_serv`;
  let clas_icf_impl = `zcl${name}icf_impl`;
  let clas_client = `zcl${name}client`;
  let intf = `zif${name}interface`;

  if (!url.startsWith("http") && number !== undefined && number !== "") {
    clas_icf_serv += number;
    clas_icf_impl += number;
    clas_client += number;
    intf += number;
  }

  const input = new abap.types.Structure({
    clas_icf_serv: new abap.types.Character(30).set(clas_icf_serv),
    clas_icf_impl: new abap.types.Character(30).set(clas_icf_impl),
    clas_client: new abap.types.Character(30).set(clas_client),
    intf: new abap.types.Character(30).set(intf),
    openapi_json: new abap.types.String().set(spec),
  });
  const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v2({
    is_input: input,
  });

  fs.writeFileSync(
    folder + clas_icf_serv + ".clas.abap",
    result.get().clas_icf_serv.get()
  );
  fs.writeFileSync(
    folder + clas_icf_impl + ".clas.abap",
    result.get().clas_icf_impl.get()
  );
  fs.writeFileSync(
    folder + clas_client + ".clas.abap",
    result.get().clas_client.get()
  );
  fs.writeFileSync(folder + intf + ".intf.abap", result.get().intf.get());

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
