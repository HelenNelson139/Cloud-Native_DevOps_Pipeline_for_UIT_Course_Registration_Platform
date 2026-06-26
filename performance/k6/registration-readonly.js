import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

const BASE_URL = (__ENV.BASE_URL || 'http://20.44.237.162').replace(/\/$/, '');
const STUDENT_ID = __ENV.STUDENT_ID || '23520718';
const PASSWORD = __ENV.PASSWORD || 'password';
const VUS = Number(__ENV.VUS || 20);
const DURATION = __ENV.DURATION || '3m';
const THINK_TIME_SECONDS = Number(__ENV.THINK_TIME_SECONDS || 1);

export const options = {
  scenarios: {
    readonly_user_flow: {
      executor: 'constant-vus',
      vus: VUS,
      duration: DURATION,
      gracefulStop: '30s',
    },
  },
  thresholds: {
    checks: ['rate>0.95'],
    http_req_failed: ['rate<0.02'],
    http_req_duration: ['p(95)<1500', 'p(99)<3000'],
    login_duration: ['p(95)<1500'],
    courses_duration: ['p(95)<1200'],
    registrations_duration: ['p(95)<1500'],
  },
};

const loginDuration = new Trend('login_duration', true);
const coursesDuration = new Trend('courses_duration', true);
const registrationsDuration = new Trend('registrations_duration', true);
const authFailures = new Counter('auth_failures');
const businessFailures = new Rate('business_failures');

function jsonHeaders(token) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }
  return { headers };
}

function timedGet(path, token, metric, tags) {
  const res = http.get(`${BASE_URL}${path}`, {
    ...jsonHeaders(token),
    tags,
  });
  metric.add(res.timings.duration, tags);
  return res;
}

function login() {
  const res = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({ studentId: STUDENT_ID, password: PASSWORD }),
    {
      ...jsonHeaders(),
      tags: { endpoint: 'login' },
    },
  );

  loginDuration.add(res.timings.duration, { endpoint: 'login' });
  const ok = check(res, {
    'login status is 201 or 200': (r) => r.status === 201 || r.status === 200,
    'login returns access token': (r) => Boolean(r.json('accessToken')),
  });

  if (!ok) {
    authFailures.add(1);
    businessFailures.add(1);
    return null;
  }

  businessFailures.add(0);
  return res.json('accessToken');
}

export default function () {
  let token;

  group('auth', () => {
    token = login();
  });

  if (!token) {
    sleep(THINK_TIME_SECONDS);
    return;
  }

  group('course read APIs', () => {
    const courses = timedGet('/api/courses', token, coursesDuration, { endpoint: 'courses' });
    check(courses, {
      'courses status is 200': (r) => r.status === 200,
      'courses response is array': (r) => Array.isArray(r.json()),
    });

    const stats = timedGet('/api/courses/stats', token, coursesDuration, { endpoint: 'course_stats' });
    check(stats, {
      'course stats status is 200': (r) => r.status === 200,
      'course stats response is array': (r) => Array.isArray(r.json()),
    });
  });

  group('registration read APIs', () => {
    const available = timedGet(
      '/api/registrations/available-classes',
      token,
      registrationsDuration,
      { endpoint: 'available_classes' },
    );
    check(available, {
      'available classes status is 200': (r) => r.status === 200,
      'available classes response is array': (r) => Array.isArray(r.json()),
    });

    const mine = timedGet('/api/registrations/my-classes', token, registrationsDuration, { endpoint: 'my_classes' });
    check(mine, {
      'my classes status is 200': (r) => r.status === 200,
      'my classes response is array': (r) => Array.isArray(r.json()),
    });
  });

  businessFailures.add(0);
  sleep(THINK_TIME_SECONDS);
}

