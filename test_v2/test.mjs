import { execSync } from "child_process";
import * as fs from "fs";
import * as path from "path";

await import("../output/init.mjs");

async function run() {
  const root = "./test_v2/";

  for (const d of fs.readdirSync(root, { withFileTypes: true })) {
    if (d.isDirectory() === false) {
      continue;
    }

    const folderName = d.name;
    const folder = root + folderName + path.sep;

    console.log("* " + folderName);

    const output = execSync(
      "node " +
        root +
        "index.mjs " +
        folder +
        "/spec.json " +
        root +
        path.sep +
        folderName
    );

    const text = output.toString();
    if (text !== "") {
      console.log(text);
    }
  }
}

console.log("V2 testing");
await run();
