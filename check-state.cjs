// Diagnostic only: no repairs, authentication, model calls, or config contents.
const fs = require('node:fs');
const path = require('node:path');
function redact(value, secrets = []) {
  let s = String(value);
  for (const secret of secrets.filter(x => typeof x === 'string' && x.length >= 8).sort((a,b)=>b.length-a.length)) s=s.split(secret).join('[REDACTED]');
  return s.replace(/Bearer\s+\S+/gi,'Bearer [REDACTED]')
    .replace(/\b(?:sk-|ntn_|secret_|gh[pousr]_)[A-Za-z0-9_-]+/g,'[REDACTED]')
    .replace(/\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)?/g,'[REDACTED]')
    .replace(/([?&](?:token|key|code|secret|password|access_token)=)[^\s&#]+/gi,'$1[REDACTED]')
    .replace(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi,'[EMAIL]')
    .replace(/\b[A-Za-z0-9_-]{40,}\b/g,'[OPAQUE-ID]')
    .slice(0,700);
}
function collectSecrets(value, inherited=false, out=[]) {
  if (!value || typeof value!=='object') return out;
  for (const [key,v] of Object.entries(value)) {
    const sensitive=inherited || /token|password|secret|api.?key|authorization|credential/i.test(key);
    if (typeof v==='string' && sensitive) out.push(v);
    else if(v && typeof v==='object') collectSecrets(v,sensitive,out);
  }
  return out;
}
function errorTree(error,secrets=[],seen=new Set(),depth=0) {
  if(!error || depth>5 || seen.has(error)) return undefined;
  if(typeof error!=='object') return {message:redact(error,secrets)};
  seen.add(error);
  return {name:redact(error.name||'Error',secrets),...(error.code ? {code:redact(error.code,secrets)}:{}),message:redact(error.message||'No message',secrets),...(error.cause?{cause:errorTree(error.cause,secrets,seen,depth+1)}:{}),...(Array.isArray(error.errors)?{errors:error.errors.slice(0,8).map(e=>errorTree(e,secrets,seen,depth+1)).filter(Boolean)}:{})};
}
async function main() {
  const state=process.env.OPENCLAW_STATE_DIR;
  const config=process.env.OPENCLAW_CONFIG_PATH;
  if(!state || !config || !path.isAbsolute(state) || path.resolve(config)!==path.join(path.resolve(state),'openclaw.json')) throw Error('Expected explicit independent profile paths; refusing discovery of other profiles.');
  const report={kind:'personal-lobster-state-diagnostic',node:process.version,uid:process.getuid?.(),gid:process.getgid?.(),repairsAttempted:false};
  let secrets=[];
  try { const raw=fs.readFileSync(config,'utf8');const obj=JSON.parse(raw);secrets=collectSecrets(obj);report.configJsonReadable=true; }
  catch(e) { report.configJsonReadable=false;report.configFileError={name:e.name,code:e.code||null}; }
  report.files=[];
  for(const rel of ['.','openclaw.json','state','state/openclaw.sqlite','state/openclaw.sqlite-wal','state/openclaw.sqlite-shm']){
    try {const st=fs.lstatSync(path.join(state,rel));report.files.push({path:rel,mode:(st.mode&0o777).toString(8),uid:st.uid,gid:st.gid,size:st.size,symlink:st.isSymbolicLink()});}
    catch(e){report.files.push({path:rel,error:e.code||e.name});}
  }
  const originalError=console.error,originalWarn=console.warn;
  console.error=(...args)=>originalError(...args.map(a=>redact(typeof a==='string'?a:a?.message||String(a),secrets)));
  console.warn=(...args)=>originalWarn(...args.map(a=>redact(typeof a==='string'?a:a?.message||String(a),secrets)));
  try {
    const m=await import('/app/dist/config/config.js');
    const result=await m.readConfigFileSnapshotWithPluginMetadata({observe:false,recoverSuspicious:false});
    const s=result.snapshot;
    report.snapshotValid=s.valid;
    report.issues=(s.issues||[]).slice(0,8).map(i=>({code:i.errorCode||null,path:i.path||'',...(i.cause?{error:errorTree(i.cause,secrets)}:{})}));
  }catch(e){report.snapshotError=errorTree(e,secrets);}
  finally{console.error=originalError;console.warn=originalWarn;}
  console.log(JSON.stringify(report,null,2));
}
module.exports={redact,collectSecrets,errorTree,main};
if(require.main===module) main().catch(e=>{console.error(JSON.stringify({diagnosticError:errorTree(e)}));process.exitCode=1;});
