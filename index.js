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

  const zcl_aopi_main = require("./output/zcl_aopi_main.clas.js").zcl_aopi_main;
  const main = new zcl_aopi_main();
  await main.constructor_();
  const result = await main.run({iv_json: spec});

  console.log(abap.console.get());

  fs.writeFileSync(process.cwd() + path.sep + "result" + path.sep + "zcl_bar.clas.abap", result.get().clas.get());
  fs.writeFileSync(process.cwd() + path.sep + "result" + path.sep + "zif_bar.intf.abap", result.get().intf.get());
}

run().then().catch(err => {
  console.dir(err);
  process.exit(1);
});