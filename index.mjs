import * as https from "https";
import * as fs from "fs";
import * as path from "path";

await import("./output/init.mjs");

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

  const input = new abap.types.Structure({
    class_name: new abap.types.Character({length: 30}),
    interface_name: new abap.types.Character({length: 30}),
    json: new abap.types.String()}
  );
  input.get().json.set(spec);
  input.get().class_name.set('zcl_' + process.argv[3]);
  input.get().interface_name.set('zif_' + process.argv[3]);
  const result = await abap.Classes["ZCL_OAPI_GENERATOR"].generate_v1({is_input: input});

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