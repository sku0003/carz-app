const fs = require('fs');
const path = require('path');

const source = path.join(__dirname, 'data', 'store.json');
const destinationDir = path.join(__dirname, 'backups');
if (!fs.existsSync(source)) process.exit(0);
fs.mkdirSync(destinationDir, { recursive: true });
const stamp = new Date().toISOString().replace(/[:.]/g, '-');
fs.copyFileSync(source, path.join(destinationDir, `store-${stamp}.json`));
console.log(`Backup created: ${stamp}`);
