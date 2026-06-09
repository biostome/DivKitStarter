const fs = require("fs/promises");
const path = require("path");

const repo = "https://api.github.com/repos/divkit/divkit/contents/schema";
const rawBase = "https://raw.githubusercontent.com/divkit/divkit/main/schema";
const outputDirectory = path.resolve(__dirname, "..", "schema", "divkit");

async function main() {
  await fs.mkdir(outputDirectory, { recursive: true });

  const response = await fetch(repo, {
    headers: {
      "User-Agent": "DivKitStarter",
      Accept: "application/vnd.github+json",
    },
  });
  if (!response.ok) {
    throw new Error(`Failed to list DivKit schema: ${response.status}`);
  }

  const files = await response.json();
  const jsonFiles = files.filter((file) => file.type === "file" && file.name.endsWith(".json"));

  for (const file of jsonFiles) {
    const schemaResponse = await fetch(`${rawBase}/${file.name}`);
    if (!schemaResponse.ok) {
      throw new Error(`Failed to download ${file.name}: ${schemaResponse.status}`);
    }
    await fs.writeFile(path.join(outputDirectory, file.name), await schemaResponse.text());
  }

  console.log(`Downloaded ${jsonFiles.length} DivKit schema files to ${outputDirectory}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
