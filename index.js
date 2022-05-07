const yargs = require("yargs/yargs");
const {hideBin} = require("yargs/helpers");
const fs = require("fs");

let options = {};
let inputContent;

const parseArgs = () => {
    const argv = yargs(hideBin(process.argv))
        .option("typedef", {
            alias: "t",
            type: "boolean",
            description: "If structure should be generated with typedef",
            default: true
        })
        .option("outputFile", {
            alias: "o",
            type: "string",
            description: "Output file",
            default: "output.json"
        })
        .option("inputFile", {
            alias: "i",
            type: "string",
            description: "Input file",
            default: "input.json"
        })
        .parse();
    options.typedef = argv.typedef;
    options.outputFile = argv.outputFile;
    options.inputFile = argv.inputFile;
    console.log("Options:", options);
}

const checkFile = () => {
    if (!fs.existsSync(options.inputFile)) {
        console.error("Input file does not exist");
        process.exit(1);
    }
    const input = fs.readFileSync(options.inputFile, "utf-8");
    try {
        inputContent = JSON.parse(input);
    } catch (err) {
        console.error("Input file is not a valid JSON");
        process.exit(1);
    }
}

const fillStructures = (keys, structures) => {
    for (let key of keys) {
        let structure = {name: key, fields: []};
        let fields = Object.keys(inputContent[key]);
        if (fields.length === 0) {
            console.error("Empty fields for structure: ", key);
            process.exit(1);
        }
        for (let field of fields) {
            let fieldType = inputContent[key][field];
            if (fieldType === undefined) {
                console.error("Undefined field type for field: ", field);
                process.exit(1);
            }
            structure.fields.push({name: field, type: fieldType});
        }
        structures.push(structure);
    }
}

const transformJson = () => {
    console.log("Transforming JSON...");
    console.log("Input:", inputContent);

    const keys = Object.keys(inputContent);
    if (keys.length === 0) {
        console.error("Input is empty");
        process.exit(1);
    }

    let structures = [];
    fillStructures(keys, structures);
    let structuresLength = structures.length;

    let data = "";
    for (let i = 0; i < structures.length; i++) {
        if (options.typedef)
            data += "typedef struct {\n";
        else
            data += `struct ${structures[i].name} {\n`;

        for (let field of structures[i].fields)
            data += `\t${field.type} ${field.name};\n`;
        data += "}";

        if (options.typedef)
            data += ` ${structures[i].name}_t;\n`;
        else
            data += "\n";

        if (i < structuresLength - 1)
            data += "\n";
    }
    fs.writeFileSync(options.outputFile, data);
}

const main = async () => {
    console.log("Starting...");
    parseArgs();
    console.log("[+] Parsing arguments");
    checkFile();
    transformJson();
}

main().catch(console.error);
