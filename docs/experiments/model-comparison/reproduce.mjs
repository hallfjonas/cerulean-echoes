import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..', '..');
const { runs } = JSON.parse(readFileSync(join(here, 'sessions.json'), 'utf8'));
const scratch = mkdtempSync(join(tmpdir(), 'model-comparison-'));

function gitShow(ref, path) {
  return execFileSync('git', ['show', `${ref}:${path}`], {
    cwd: repo,
    encoding: 'utf8',
    maxBuffer: 1 << 26,
    stdio: ['ignore', 'pipe', 'ignore'],
  });
}

function fromGit(refs, path, name) {
  const failures = [];
  for (const ref of [].concat(refs)) {
    try {
      const file = join(scratch, name);
      writeFileSync(file, gitShow(ref, path));
      return file;
    } catch (error) {
      failures.push(ref);
    }
  }
  throw new Error(`${path} not found on ${failures.join(', ')}; run git fetch origin`);
}

const reference = fromGit('origin/main', 'tracks/techno/008-groove-techno/008-groove-techno.strudel', '008.strudel');
const skipAudibility = process.argv.includes('--no-audibility');

const lines = (file) => readFileSync(file, 'utf8').split('\n');

function sharedWithReference(file) {
  const reference008 = new Set(lines(reference).map((l) => l.trim()).filter(Boolean));
  const own = lines(file).map((l) => l.trim()).filter(Boolean);
  return own.filter((l) => reference008.has(l)).length / own.length;
}

function recording(name) {
  return JSON.parse(readFileSync(join(here, 'recordings-sidecars', `${name}.json`), 'utf8'));
}

function audibility(file) {
  const out = execFileSync('node', ['strudel-sim/audibility.mjs', file], {
    cwd: join(repo, 'tools'),
    encoding: 'utf8',
    maxBuffer: 1 << 24,
  });
  const rows = out.split('\n').filter((l) => /^(MIX|stem[JN]\d)/.test(l));
  const mix = rows.find((l) => l.startsWith('MIX')).trim().split(/\s+/);
  const stems = rows.filter((l) => l.startsWith('stem'));
  return {
    mixLufs: Number(mix[1]),
    mixPeak: Number(mix[3]),
    stems: stems.length,
    silentAtDefault: stems.filter((l) => l.includes('SILENT')).length,
    kickLufs: Number(stems.find((l) => l.includes('J1_kick')).trim().split(/\s+/)[1]),
    hatsLufs: Number(stems.find((l) => l.includes('J6_hats')).trim().split(/\s+/)[1]),
  };
}

const rows = Object.entries(runs).map(([name, run]) => {
  const file = fromGit([`origin/${run.branch}`, 'origin/main'], run.trackPath, `${name}.strudel`);
  const text = readFileSync(file, 'utf8');
  const rec = recording(name);
  const bpm = Number(/const bpm *= *(\d+)/.exec(text)?.[1] ?? /(\d+) BPM/.exec(text)?.[1]);
  const wallSeconds = (Date.parse(run.finishedAt) - Date.parse(run.startedAt)) / 1000;
  return {
    model: run.model,
    pr: `#${run.pr}`,
    prompt: run.promptKind,
    buildMinutes: +(wallSeconds / 60).toFixed(1),
    turns: run.turns,
    messages: run.messages,
    recordingSeconds: Math.round(rec.seconds),
    recordingStartCycle: +rec.startCycle.toFixed(1),
    bpm,
    bpmInRange: bpm >= 130 && bpm <= 140,
    linesSharedWith008: `${Math.round(sharedWithReference(file) * 100)}%`,
    ...(skipAudibility ? {} : audibility(file)),
  };
});

console.table(rows);
