import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import net from 'node:net';
import {randomBytes} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

export const PACKAGE = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export function readSettings(root = PACKAGE) {
  const s = JSON.parse(fs.readFileSync(path.join(root, 'settings.json'), 'utf8'));
  if (!/^[a-z][a-z0-9-]{2,35}$/.test(s.profile) || s.profile === 'default') throw Error('Invalid independent profile name');
  if (!Number.isInteger(s.port) || s.port < 1024 || s.port > 65425) throw Error('Invalid base port');
  if (!/^openai\/[a-zA-Z0-9._-]+$/.test(s.model)) throw Error('Use an available official openai model');
  return s;
}
function ordinary(p) {
  if (fs.existsSync(p) || (() => {try {fs.lstatSync(p); return true;} catch {return false;}})()) {
    if (fs.lstatSync(p).isSymbolicLink()) throw Error('Refusing symbolic-link destination: ' + p);
  }
}
export function profilePaths(home, settings) {
  const state = path.join(home, '.openclaw-' + settings.profile);
  return {state, config: path.join(state, 'openclaw.json'), workspace: path.join(state, 'workspace'), marker: path.join(state, '.personal-lobster-kit.json')};
}
export function isolatedEnv(source, p, settings) {
  const env = {...source};
  for (const key of Object.keys(env)) {
    if (/^(OPENCLAW_|CODEX_HOME$|OPENAI_|ANTHROPIC_|DISCORD_|TELEGRAM_|LINE_CHANNEL_|NOTION_|N8N_|GH_TOKEN$|GITHUB_TOKEN$)/i.test(key)) delete env[key];
  }
  return {...env, OPENCLAW_PROFILE: settings.profile, OPENCLAW_STATE_DIR: p.state, OPENCLAW_CONFIG_PATH: p.config};
}
export function initProfile({home = os.homedir(), root = PACKAGE, settings = readSettings(root)} = {}) {
  const p = profilePaths(home, settings);
  ordinary(p.state);
  if (fs.existsSync(p.state) && !fs.existsSync(p.marker) && fs.readdirSync(p.state).length) throw Error('Existing unrecognized profile; refusing to adopt or overwrite it. Choose another settings.json profile.');
  fs.mkdirSync(p.state, {recursive: true, mode: 0o700});
  ordinary(p.marker); ordinary(p.config); ordinary(p.workspace);
  if (!fs.existsSync(p.marker)) fs.writeFileSync(p.marker, JSON.stringify({kit: 1, profile: settings.profile, port: settings.port}) + '\n', {flag: 'wx', mode: 0o600});
  const marker = JSON.parse(fs.readFileSync(p.marker, 'utf8'));
  if (marker.kit !== 1 || marker.profile !== settings.profile || marker.port !== settings.port) throw Error('Profile/port changed; use another profile rather than overwrite an installation.');
  fs.mkdirSync(p.workspace, {recursive: true, mode: 0o700});
  function copyMissing(src, dest) {
    for (const entry of fs.readdirSync(src, {withFileTypes: true})) {
      const a = path.join(src, entry.name), b = path.join(dest, entry.name);
      if (entry.isSymbolicLink()) throw Error('Template symlinks are not permitted');
      ordinary(b);
      if (entry.isDirectory()) {fs.mkdirSync(b, {recursive: true, mode: 0o700}); copyMissing(a, b);}
      else if (entry.isFile() && !fs.existsSync(b)) fs.copyFileSync(a, b, fs.constants.COPYFILE_EXCL);
    }
  }
  copyMissing(path.join(root, 'workspace'), p.workspace);
  if (!fs.existsSync(p.config)) {
    const config = JSON.parse(fs.readFileSync(path.join(root, 'openclaw.template.json'), 'utf8'));
    config.gateway.port = settings.port;
    config.gateway.auth.token = randomBytes(32).toString('hex');
    config.gateway.controlUi.allowedOrigins = [`http://127.0.0.1:${settings.port}`, `http://localhost:${settings.port}`];
    config.agents.defaults.model.primary = settings.model;
    config.agents.entries.main.workspace = p.workspace;
    fs.writeFileSync(p.config, JSON.stringify(config, null, 2) + '\n', {flag: 'wx', mode: 0o600});
  }
  const config = JSON.parse(fs.readFileSync(p.config, 'utf8'));
  if (config.gateway?.port !== settings.port || config.agents?.entries?.main?.workspace !== p.workspace) throw Error('Existing profile topology differs; not changing it automatically.');
  return p;
}
export function claw(args, {p, settings, capture = false, allowFailure = false} = {}) {
  const argv = ['--profile', settings.profile, ...args];
  const env = isolatedEnv(process.env, p, settings);
  let result;
  if (process.platform === 'win32') {
    const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'lobster-cli-'));
    const file = path.join(temp, 'arguments.json');
    try {
      fs.writeFileSync(file, JSON.stringify(argv), {mode: 0o600});
      result = spawnSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(PACKAGE, 'windows', 'invoke-openclaw.ps1'), '-ArgumentsFile', file], {env, stdio: capture ? 'pipe' : 'inherit', encoding: 'utf8'});
    } finally {fs.rmSync(temp, {recursive: true, force: true});}
  } else result = spawnSync('openclaw', argv, {env, stdio: capture ? 'pipe' : 'inherit', encoding: 'utf8'});
  if (result.error) throw result.error;
  if (result.status !== 0 && !allowFailure) throw Error('OpenClaw step failed: ' + args.slice(0, 3).join(' ') + '. No success is assumed; rerun after fixing the displayed error.');
  return result;
}
async function portFree(port) {
  return await new Promise(resolve => {
    const server = net.createServer();
    server.once('error', () => resolve(false));
    server.listen(port, '127.0.0.1', () => server.close(() => resolve(true)));
  });
}
async function start(context, foreground = false) {
  const {settings} = context;
  if (!await portFree(settings.port)) {
    const probe = claw(['health', '--json'], {...context, capture: true, allowFailure: true});
    if (probe.status !== 0) throw Error('Port occupied by an unknown/unhealthy process. It will NOT be killed. Choose a new profile and port.');
    console.log('This profile is already healthy.');
    return true;
  }
  if (foreground) {claw(['gateway', 'run', '--port', String(settings.port)], context); return false;}
  const installed = claw(['gateway', 'install', '--port', String(settings.port)], {...context, allowFailure: true});
  if (installed.status !== 0) {
    console.log('Managed service unavailable. Use the platform START file with serve for foreground mode. No default service was changed.');
    return false;
  }
  for (let attempt = 0; attempt < 12; attempt++) {
    const health = claw(['health', '--json'], {...context, capture: true, allowFailure: true});
    if (health.status === 0) {console.log('Gateway health check passed.'); return true;}
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  throw Error('Service requested but health not yet confirmed. Run doctor or serve; not claiming successful deployment.');
}
export async function main(argv = process.argv.slice(2)) {
  const action = argv[0] || 'setup';
  if (!['setup', 'init', 'login', 'start', 'serve', 'doctor', 'dashboard', 'channels', 'stop', 'models'].includes(action)) throw Error('Unknown action');
  const settings = readSettings();
  const p = initProfile({settings});
  const context = {p, settings};
  console.log('Independent profile: ' + settings.profile + '\nWorkspace: ' + p.workspace);
  if (action === 'init') return;
  claw(['config', 'validate'], context);
  if (action === 'setup' || action === 'login') {
    console.log('Sign in using YOUR OWN ChatGPT/Codex account. The device code is shown only in this terminal.');
    claw(['models', 'auth', 'login', '--provider', 'openai', '--device-code'], context);
    claw(['config', 'validate'], context);
    claw(['models', 'list', '--provider', 'openai'], context);
    if (action === 'login') return;
  }
  if (action === 'start' || action === 'serve' || action === 'setup') {
    const healthy = await start(context, action === 'serve');
    if (healthy && action === 'setup') {
      console.log('Gateway is ready; model reply still needs your first real chat test.');
      claw(['dashboard', '--no-open'], context);
    }
  } else if (action === 'doctor') {
    claw(['doctor'], context);
  } else if (action === 'dashboard') {
    claw(['dashboard'], context);
  } else if (action === 'channels') {
    claw(['configure', '--section', 'channels'], context);
  } else if (action === 'stop') {
    claw(['gateway', 'stop'], context);
  } else if (action === 'models') {
    claw(['models', 'list', '--all', '--provider', 'openai'], context);
  }
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().catch(error => {console.error('STOP: ' + error.message); process.exitCode = 1;});
}
