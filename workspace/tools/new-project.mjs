import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export function stageProject({root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..'), id, name = id} = {}) {
  if (typeof id !== 'string' || !/^[a-z][a-z0-9-]{2,35}$/.test(id) || ['main','default','reviewer'].includes(id)) throw Error('Use a new lowercase project ID, not a shared role or path.');
  if (typeof name !== 'string' || !name.trim() || name.length > 120 || /[\r\n\0]/.test(name)) throw Error('Invalid project name.');
  root = path.resolve(root);
  const ordinary = p => { try { if (fs.lstatSync(p).isSymbolicLink()) throw Error('Refusing symbolic-link path.'); } catch (error) { if (error.code !== 'ENOENT') throw error; } };
  ordinary(root);
  if (!fs.statSync(root).isDirectory()) throw Error('Use the existing installed workspace.');
  const projects = path.join(root, 'projects'); ordinary(projects);
  const destination = path.join(projects, id); ordinary(destination);
  if (fs.existsSync(destination)) throw Error('Project already exists; preserving every file.');
  const role = path.join(root, 'roles', 'PROJECT-AGENTS.md'); ordinary(path.dirname(role)); ordinary(role);
  const roleText = fs.readFileSync(role, 'utf8');
  fs.mkdirSync(projects, {recursive:true, mode:0o700});
  // Build in a temporary folder, then reserve the final ID atomically.
  // An interrupted move may leave a HELD partial folder, never an active agent.
  const temporary = fs.mkdtempSync(path.join(projects, '.new-project-'));
  try {
    fs.mkdirSync(path.join(temporary, 'workspace'), {mode:0o700});
    fs.mkdirSync(path.join(temporary, 'workspace', 'memory'), {mode:0o700});
    const write = (relative, content) => fs.writeFileSync(path.join(temporary, relative), content, {flag:'wx', mode:0o600});
    write('PERSONA.md', '# ' + name.trim() + '\n\n專案角色草稿，僅本案；具體語氣與授權由本人確認。方法沿用專案工程師範本，不攜帶總部私人記憶。\n');
    write('STATUS.md', '# ' + name.trim() + ' — STATUS\n\n## 目前狀態\nHELD：只建立骨架，未建立執行agent／binding／沙盒或憑證。\n\n## 接續工作\n- 目標／授權：待本人填入具體本案需求；建立骨架不是業務操作授權。\n- 完成：本案檔案骨架。\n- 證據／限制：尚無原生工具、mount、scope或路由驗收。\n- 下一步：總助理核對本人scope，登記專案索引，完成隔離門檻後才啟用。\n');
    write('workspace/AGENTS.md', roleText);
    write('workspace/PERSONA.md', '# 本案角色入口\n\n只使用部署者為本案提供的PERSONA與方法。啟用前須精準掛載本案PERSONA及唯一STATUS；不讀取另一案或總部私人記憶。\n');
    write('workspace/memory/README.md', '本案獨有記憶；不要複製總部或其他專案對話。\n');
    write('REGISTRATION.json', JSON.stringify({schema_version:1,id,name:name.trim(),state:'HELD',runtime_agent_created:false,binding_enabled:false,credentials_granted:false,canonical_status:'STATUS.md',workspace:'workspace',gates:{owner_scope:false,native_agent_execution:false,independent_mount_network:false,cross_project_refusal:false,exact_route:false}},null,2)+'\n');
    ordinary(destination); if (fs.existsSync(destination)) throw Error('Concurrent project creation detected.');
    fs.mkdirSync(destination,{mode:0o700});
    for (const entry of fs.readdirSync(temporary)) fs.renameSync(path.join(temporary,entry),path.join(destination,entry));
    fs.rmdirSync(temporary);
    return {id,state:'HELD',path:destination,liveConfigurationChanged:false};
  } catch (error) { fs.rmSync(temporary,{recursive:true,force:true}); throw error; }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [id, ...words] = process.argv.slice(2);
  try { console.log(JSON.stringify(stageProject({id,name:words.join(' ')||id}),null,2)); }
  catch (error) { console.error('STOP: '+error.message); process.exitCode=1; }
}
