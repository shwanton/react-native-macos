// @ts-check
const chalk = require('chalk');
const child_process = require('child_process');
const fs = require('fs');

/** Run a shell command and return any relevant error that comes up. */
function exec(command) {
  console.log(chalk.grey(`$ ${command}`))
  try {
    child_process.execSync(command, {stdio: ['pipe', 'inherit', 'pipe']});
    return undefined;
  } catch (error) {
    return error;
  }
}

function logError(error) {
  console.error(error.stderr.toString());
}

console.log('Attempting `bundle install` on its own...')
const plainResultError = exec('bundle install');
if (plainResultError === undefined) {
  process.exit(0);
} else {
  logError(plainResultError);
}

// Try to find the version error
const errorMessage = plainResultError.stderr.toString();
const versionErrorMatch = errorMessage.match(/Your Ruby version is ([\d\.]+), but your Gemfile specified ([\d\.]+)/);
if (versionErrorMatch === undefined) {
  console.error('Unrecognized error, bailing out');
  process.exit(1);
}

let systemRubyVersion = versionErrorMatch[1];
let gemfileRubyVersion = versionErrorMatch[2];

console.log(`Attempting to install Ruby ${gemfileRubyVersion}...`);
const rubyInstallError = exec(`rbenv install -s ${gemfileRubyVersion}`);
if (rubyInstallError !== undefined) {
  logError(rubyInstallError);

  console.log(`Attempting to use system version of Ruby ${systemRubyVersion}...`);

  // Remove ruby version from Gemfile
  const gemfileContents = fs.readFileSync('Gemfile').toString();
  const newGemfileContents = gemfileContents.split('\n').filter(line => {
    return line.match(/^ruby\s+'(.+)'$/) === null;
  }).join('\n');
  fs.writeFileSync('Gemfile', newGemfileContents);

  fs.rmSync('.ruby-version');
}

console.log('Trying again with `rbenv`...');
const rbenvError = exec('rbenv exec bundle install');
if (rbenvError !== undefined) {
  logError(rbenvError);
  process.exit(1);
}
