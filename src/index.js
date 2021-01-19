import * as https from "https";
import * as fs from "fs";
import * as path from "path";
import Mustache from "mustache";
import * as url from 'url';

// https://github.com/nodejs/help/issues/2907
const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function get(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, (res) => {
      res.setEncoding("utf8");
      let responseBody = "";

      res.on("data", (chunk) => {
        responseBody += chunk;
      });

      res.on("end", () => {
        resolve(JSON.parse(responseBody));
      });
    });

    req.on("error", (err) => {
      reject(err);
    });

    req.end();
  });
}

async function run() {
  const spec = await get("https://petstore3.swagger.io/api/v3/openapi.json");

  const intfTemplate = fs.readFileSync(__dirname + path.sep + "interface.mustache").toString();
  const clasTemplate = fs.readFileSync(__dirname + path.sep + "class.mustache").toString();

  const intf = Mustache.render(intfTemplate, spec);
  const clas = Mustache.render(clasTemplate, spec);

  fs.writeFileSync(process.cwd() + path.sep + "output" + path.sep + "zcl_bar.clas.abap", clas);
  fs.writeFileSync(process.cwd() + path.sep + "output" + path.sep + "zif_bar.intf.abap", intf);
}

run().then().catch(err => {
  console.dir(err);
  process.exit(1);
});