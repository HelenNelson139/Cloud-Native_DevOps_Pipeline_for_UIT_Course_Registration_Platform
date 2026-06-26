#!/usr/bin/env node

const { performance } = require('node:perf_hooks');
const fs = require('node:fs');
const path = require('node:path');

const args = parseArgs(process.argv.slice(2));

const baseUrl = stripTrailingSlash(args.baseUrl || process.env.BASE_URL || 'http://20.44.237.162');
const studentId = args.studentId || process.env.STUDENT_ID || '23520718';
const password = args.password || process.env.PASSWORD || 'password';
const vus = Number(args.vus || process.env.VUS || 20);
const durationSeconds = parseDurationSeconds(args.duration || process.env.DURATION || '180s');
const thinkMs = Number(args.thinkMs || process.env.THINK_MS || 1000);
const outFile = args.out || process.env.OUT_FILE || 'performance/reports/node-load-summary.json';

const endpoints = [
  { name: 'courses', method: 'GET', path: '/api/courses', auth: true },
  { name: 'course_stats', method: 'GET', path: '/api/courses/stats', auth: true },
  { name: 'available_classes', method: 'GET', path: '/api/registrations/available-classes', auth: true },
  { name: 'my_classes', method: 'GET', path: '/api/registrations/my-classes', auth: true },
];

const state = {
  startedAt: new Date().toISOString(),
  baseUrl,
  vus,
  durationSeconds,
  thinkMs,
  requests: [],
  checks: { passed: 0, failed: 0 },
  endpointCounts: new Map(),
};

function parseArgs(argv) {
  const result = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      result[key] = true;
    } else {
      result[key] = next;
      i += 1;
    }
  }
  return result;
}

function stripTrailingSlash(value) {
  return String(value).replace(/\/$/, '');
}

function parseDurationSeconds(value) {
  const text = String(value).trim();
  const match = text.match(/^(\d+)(ms|s|m)?$/);
  if (!match) throw new Error(`Invalid duration: ${value}`);
  const amount = Number(match[1]);
  const unit = match[2] || 's';
  if (unit === 'ms') return amount / 1000;
  if (unit === 'm') return amount * 60;
  return amount;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function percentile(values, p) {
  if (values.length === 0) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const index = Math.ceil((p / 100) * sorted.length) - 1;
  return sorted[Math.max(0, Math.min(sorted.length - 1, index))];
}

function recordCheck(ok) {
  if (ok) state.checks.passed += 1;
  else state.checks.failed += 1;
}

function recordRequest(sample) {
  state.requests.push(sample);
  state.endpointCounts.set(sample.endpoint, (state.endpointCounts.get(sample.endpoint) || 0) + 1);
}

async function timedRequest(endpoint, token, vu) {
  const started = performance.now();
  let status = 0;
  let ok = false;
  let error = null;

  try {
    const headers = { 'Content-Type': 'application/json' };
    if (endpoint.auth) headers.Authorization = `Bearer ${token}`;

    const response = await fetch(`${baseUrl}${endpoint.path}`, {
      method: endpoint.method,
      headers,
    });
    status = response.status;
    ok = response.ok;
    if (response.headers.get('content-type')?.includes('application/json')) {
      await response.json();
    } else {
      await response.text();
    }
  } catch (err) {
    error = err.message;
  }

  const durationMs = performance.now() - started;
  recordRequest({ endpoint: endpoint.name, vu, status, ok, durationMs, error });
  recordCheck(ok);
}

async function login(vu) {
  const started = performance.now();
  let status = 0;
  let ok = false;
  let token = null;
  let error = null;

  try {
    const response = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ studentId, password }),
    });
    status = response.status;
    const payload = await response.json().catch(() => ({}));
    token = payload.accessToken || null;
    ok = response.ok && Boolean(token);
  } catch (err) {
    error = err.message;
  }

  const durationMs = performance.now() - started;
  recordRequest({ endpoint: 'login', vu, status, ok, durationMs, error });
  recordCheck(ok);
  return token;
}

async function runVu(vu, deadline) {
  while (performance.now() < deadline) {
    const token = await login(vu);
    if (token) {
      for (const endpoint of endpoints) {
        await timedRequest(endpoint, token, vu);
      }
    }
    await sleep(thinkMs);
  }
}

function summarize() {
  const endedAt = new Date().toISOString();
  const durations = state.requests.map((sample) => sample.durationMs);
  const failed = state.requests.filter((sample) => !sample.ok).length;
  const total = state.requests.length;
  const elapsedSeconds = durationSeconds;

  const byEndpoint = {};
  for (const endpoint of ['login', ...endpoints.map((item) => item.name)]) {
    const samples = state.requests.filter((sample) => sample.endpoint === endpoint);
    const endpointDurations = samples.map((sample) => sample.durationMs);
    byEndpoint[endpoint] = {
      requests: samples.length,
      failed: samples.filter((sample) => !sample.ok).length,
      p50_ms: round(percentile(endpointDurations, 50)),
      p95_ms: round(percentile(endpointDurations, 95)),
      p99_ms: round(percentile(endpointDurations, 99)),
      max_ms: round(Math.max(0, ...endpointDurations)),
    };
  }

  return {
    startedAt: state.startedAt,
    endedAt,
    baseUrl,
    vus,
    durationSeconds,
    thinkMs,
    totalRequests: total,
    failedRequests: failed,
    requestFailureRate: total === 0 ? 0 : round(failed / total, 6),
    checksPassed: state.checks.passed,
    checksFailed: state.checks.failed,
    checksPassRate: state.checks.passed + state.checks.failed === 0
      ? 0
      : round(state.checks.passed / (state.checks.passed + state.checks.failed), 6),
    avgRps: round(total / elapsedSeconds, 3),
    latency: {
      p50_ms: round(percentile(durations, 50)),
      p95_ms: round(percentile(durations, 95)),
      p99_ms: round(percentile(durations, 99)),
      max_ms: round(Math.max(0, ...durations)),
    },
    byEndpoint,
    errors: state.requests
      .filter((sample) => !sample.ok)
      .slice(0, 20)
      .map((sample) => ({
        endpoint: sample.endpoint,
        status: sample.status,
        error: sample.error,
      })),
  };
}

function round(value, digits = 2) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

async function main() {
  console.log(`read-only load: baseUrl=${baseUrl} vus=${vus} duration=${durationSeconds}s`);
  const started = performance.now();
  const deadline = started + durationSeconds * 1000;
  await Promise.all(Array.from({ length: vus }, (_, index) => runVu(index + 1, deadline)));

  const summary = summarize();
  fs.mkdirSync(path.dirname(outFile), { recursive: true });
  fs.writeFileSync(outFile, `${JSON.stringify(summary, null, 2)}\n`);

  console.log(JSON.stringify(summary, null, 2));
  console.log(`summary=${outFile}`);

  if (summary.requestFailureRate >= 0.02 || summary.checksPassRate < 0.95) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});

