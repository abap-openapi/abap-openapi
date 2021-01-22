const https = require("https");
const fs = require("fs");
const path = require("path");
const runtime = require("@abaplint/runtime");
global.abap = new runtime.ABAP();

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
  if (process.argv[2] === undefined || process.argv[2] === "") {
    throw "supply url";
  }
  const spec = await get(process.argv[2]);

  const zcl_oapi_main = require("./output/zcl_oapi_main.clas.js").zcl_oapi_main;
  const main = new zcl_oapi_main();
  await main.constructor_();

  const input = new abap.types.Structure({class_name: new abap.types.Character({length: 30}), interface_name: new abap.types.Character({length: 30}), json: new abap.types.String()});
  input.get().json.set(spec);
  input.get().class_name.set('zcl_foobar');
  input.get().interface_name.set('zif_foobar');
  const result = await main.run({is_input: input});

  console.log(abap.console.get());

  fs.writeFileSync(process.cwd() + path.sep + "result" + path.sep + input.get().class_name.get() + ".clas.abap", result.get().clas.get());
  fs.writeFileSync(process.cwd() + path.sep + "result" + path.sep + input.get().interface_name.get() + ".intf.abap", result.get().intf.get());
}

run().then().catch(err => {
  console.dir(err);
  process.exit(1);
});