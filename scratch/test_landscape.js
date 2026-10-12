const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');

const ARTIFACTS_DIR = 'C:/Users/TurboBoost/.gemini/antigravity/brain/f0024e60-442e-4c3a-96f3-83bfb5a85c3d';
const CHROME_PATH = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const DEBUG_PORT = 9338;
const TEMP_PROFILE = path.join(process.env.TEMP, 'chrome_test_land_' + Date.now());

async function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    }).on('error', reject);
  });
}

async function run() {
  const chromeProc = spawn(CHROME_PATH, [
    '--headless=new',
    '--window-size=1280,850',
    `--remote-debugging-port=${DEBUG_PORT}`,
    '--remote-allow-origins=*',
    `--user-data-dir=${TEMP_PROFILE}`,
    '--no-first-run',
    'about:blank'
  ]);

  let wsUrl = null;
  for (let i = 0; i < 20; i++) {
    await sleep(500);
    try {
      const v = await fetchJson(`http://127.0.0.1:${DEBUG_PORT}/json/version`);
      if (v?.webSocketDebuggerUrl) {
        wsUrl = v.webSocketDebuggerUrl;
        break;
      }
    } catch (e) {}
  }

  const ws = new WebSocket(wsUrl);
  await new Promise(r => ws.onopen = r);

  let idCounter = 1;
  const pending = new Map();
  ws.onmessage = e => {
    const msg = JSON.parse(e.data);
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) reject(msg.error);
      else resolve(msg.result);
    }
  };

  function send(method, params = {}) {
    return new Promise((resolve, reject) => {
      const id = idCounter++;
      pending.set(id, { resolve, reject });
      ws.send(JSON.stringify({ id, method, params }));
    });
  }

  const { targetId } = await send('Target.createTarget', { url: 'http://127.0.0.1:5050' });
  const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });

  function sendSession(method, params = {}) {
    return new Promise((resolve, reject) => {
      const id = idCounter++;
      pending.set(id, { resolve, reject });
      ws.send(JSON.stringify({ id, sessionId, method, params }));
    });
  }

  await sendSession('Page.enable');
  await sendSession('Runtime.enable');

  await sleep(1500);
  await sendSession('Runtime.evaluate', {
    expression: `
      window.localStorage.setItem('flutter.hala_onboarding_completed', 'true');
      window.localStorage.setItem('flutter.hala_active_dialect', '"saudi"');
      window.localStorage.setItem('flutter.hala_display_language', '"en"');
      window.location.reload();
    `
  });

  await sleep(5000);

  const { data } = await sendSession('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(ARTIFACTS_DIR, 'test_ipad_landscape_1280.png'), Buffer.from(data, 'base64'));
  console.log('Saved test_ipad_landscape_1280.png');

  ws.close();
  chromeProc.kill();
}

run().catch(console.error);
