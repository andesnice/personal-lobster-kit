import fs from 'node:fs';
import path from 'node:path';
import {initProfile, readSettings, profilePaths} from '../shared/deploy.mjs';

const settings = readSettings();
if (settings.profile !== 'personal-lobster' || settings.port !== 19789) throw Error('Docker internal profile/port are fixed; use .env to change host port/project name, not settings.json.');
const hostPort = Number(process.env.LOBSTER_HOST_PORT || 19789);
if (!Number.isInteger(hostPort) || hostPort < 1024 || hostPort > 65535) throw Error('Invalid Docker host port');
const expected = profilePaths('/home/node', settings);
const fresh = !fs.existsSync(expected.config);
const p = initProfile({home: '/home/node', settings});
const marker = path.join(p.state, '.docker-install.json');
if (fs.existsSync(marker)) {
  const previous = JSON.parse(fs.readFileSync(marker));
  if (previous.hostPort !== hostPort) throw Error('Existing Docker host port differs; update allowedOrigins in your own config explicitly before changing it.');
}
const config = JSON.parse(fs.readFileSync(p.config));
if (fresh) {
  config.gateway.bind = 'lan';
  config.gateway.controlUi.allowedOrigins = [`http://127.0.0.1:${hostPort}`, `http://localhost:${hostPort}`];
  fs.writeFileSync(p.config, JSON.stringify(config, null, 2) + '\n', {mode: 0o600});
} else if (config.gateway.bind !== 'lan') throw Error('Existing config is not this Docker layout; refusing automatic conversion.');
if (!fs.existsSync(marker)) fs.writeFileSync(marker, JSON.stringify({kit: 1, hostPort}) + '\n', {flag: 'wx', mode: 0o600});
function owner(dir) {
  // Only this newly dedicated named volume; do not follow workspace symlinks.
  fs.lchownSync(dir, 1000, 1000);
  if (!fs.lstatSync(dir).isDirectory()) return;
  for (const name of fs.readdirSync(dir)) owner(path.join(dir, name));
}
owner(p.state);
console.log('Dedicated Docker volume initialized. Existing notes/config/auth retained; no source credentials imported.');
