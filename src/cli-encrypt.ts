#!/usr/bin/env node
import { updateConfigWithEncryptedPassword } from './security/encryption.js';

const args = process.argv.slice(2);
const configPath = args[2] || 'openclaw.json';

if (args[0] === 'encrypt-password') {
  const password = args[1];
  if (!password) {
    console.error('Usage: npx tsx src/cli-encrypt.ts encrypt-password <password> [--config <path>]');
    console.error('Or use stdin: echo "mypassword" | npx tsx src/cli-encrypt.ts encrypt-password --config openclaw.json');
    process.exit(1);
  }
  
  updateConfigWithEncryptedPassword(configPath, password);
  console.log('Password encrypted successfully!');
  console.log(`Config file: ${configPath}`);
} else {
  console.log('Usage: npx tsx src/cli-encrypt.ts encrypt-password <password> [--config <path>]');
}
