#!/bin/bash
set -e
cd /Users/sandy/Documents/REPO/release-note-test-data

REPO="sandy-b15/release-note-test-data"

# Get GitHub token from keychain (use git credential helper)
TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill | grep "^password=" | cut -d= -f2)
if [ -z "$TOKEN" ]; then
  echo "ERROR: Could not get GitHub token from credential helper"
  exit 1
fi
echo "Got token: ${TOKEN:0:8}..."

# PR definitions - realistic release note content
# Format: "branch_name|title|description|file_path|file_content|labels"

MERGED_PRS=(
  # Features (20)
  "feat/user-auth|feat: add user authentication with JWT|Implemented JWT-based authentication with refresh tokens. Users can now sign up, log in, and maintain sessions securely.|src/auth/jwt.js|// JWT authentication module\nconst jwt = require('jsonwebtoken');\nexports.sign = (payload) => jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });\nexports.verify = (token) => jwt.verify(token, process.env.JWT_SECRET);|feature,auth"
  "feat/dark-mode|feat: add dark mode support|Added system-preference-aware dark mode with manual toggle. Persists user preference in localStorage.|src/theme/darkMode.js|// Dark mode toggle\nexport function initDarkMode() {\n  const pref = localStorage.getItem('theme') || 'system';\n  document.documentElement.dataset.theme = pref;\n}|feature,ui"
  "feat/export-csv|feat: add CSV export for reports|Users can now export any report as CSV. Supports custom column selection and date range filtering.|src/export/csv.js|// CSV export utility\nexport function toCSV(data, columns) {\n  const header = columns.join(',');\n  const rows = data.map(r => columns.map(c => r[c]).join(','));\n  return [header, ...rows].join('\\n');\n}|feature,export"
  "feat/notification-system|feat: implement real-time notifications|WebSocket-based notification system with in-app bell icon, unread count badge, and mark-as-read functionality.|src/notifications/ws.js|// WebSocket notification handler\nconst WebSocket = require('ws');\nmodule.exports = (server) => {\n  const wss = new WebSocket.Server({ server });\n  wss.on('connection', (ws) => { ws.send(JSON.stringify({ type: 'connected' })); });\n};|feature,realtime"
  "feat/search-autocomplete|feat: add autocomplete to global search|Implemented debounced autocomplete with fuzzy matching. Results show in a dropdown with keyboard navigation.|src/search/autocomplete.js|// Search autocomplete\nexport function debounce(fn, ms = 300) {\n  let timer;\n  return (...args) => { clearTimeout(timer); timer = setTimeout(() => fn(...args), ms); };\n}|feature,search"
  "feat/role-based-access|feat: implement RBAC permissions|Added role-based access control with admin, editor, and viewer roles. Middleware checks permissions on every request.|src/auth/rbac.js|// Role-based access control\nconst roles = { admin: ['read','write','delete'], editor: ['read','write'], viewer: ['read'] };\nexports.can = (role, action) => (roles[role] || []).includes(action);|feature,auth,security"
  "feat/file-upload|feat: add file upload with drag-and-drop|Implemented drag-and-drop file upload with progress bar, file type validation, and S3 storage integration.|src/upload/handler.js|// File upload handler\nconst multer = require('multer');\nconst upload = multer({ limits: { fileSize: 10 * 1024 * 1024 }, fileFilter: (req, file, cb) => cb(null, true) });\nmodule.exports = upload;|feature,storage"
  "feat/audit-log|feat: add comprehensive audit logging|All user actions are now logged with timestamp, user ID, action type, and affected resource. Queryable via admin panel.|src/audit/logger.js|// Audit logger\nexports.log = async (pool, { userId, action, resource, details }) => {\n  await pool.query('INSERT INTO audit_logs (user_id, action, resource, details) VALUES ($1,$2,$3,$4)', [userId, action, resource, JSON.stringify(details)]);\n};|feature,security"
  "feat/two-factor-auth|feat: add 2FA with TOTP|Users can enable two-factor authentication using any TOTP app (Google Authenticator, Authy). Includes backup codes.|src/auth/totp.js|// TOTP 2FA\nconst speakeasy = require('speakeasy');\nexports.generateSecret = () => speakeasy.generateSecret({ length: 20 });\nexports.verify = (secret, token) => speakeasy.totp.verify({ secret, token, encoding: 'base32' });|feature,auth,security"
  "feat/api-rate-limiting|feat: implement API rate limiting|Added per-user and per-IP rate limiting with sliding window algorithm. Returns X-RateLimit headers.|src/middleware/rateLimit.js|// Rate limiter middleware\nconst limits = new Map();\nexports.rateLimit = (max = 100, windowMs = 60000) => (req, res, next) => {\n  const key = req.user?.id || req.ip;\n  const now = Date.now();\n  // sliding window implementation\n  next();\n};|feature,security"
  "feat/webhook-system|feat: add outgoing webhook support|Users can configure webhooks to receive POST notifications on events. Includes retry logic and signature verification.|src/webhooks/dispatcher.js|// Webhook dispatcher\nconst crypto = require('crypto');\nexports.sign = (payload, secret) => crypto.createHmac('sha256', secret).update(JSON.stringify(payload)).digest('hex');\nexports.dispatch = async (url, payload, secret) => { /* fetch with retry */ };|feature,integrations"
  "feat/dashboard-widgets|feat: add customizable dashboard widgets|Users can rearrange, resize, and configure dashboard widgets. Supports charts, tables, and KPI cards.|src/dashboard/widgets.js|// Dashboard widget system\nexport const WIDGET_TYPES = ['chart', 'table', 'kpi', 'list'];\nexport function createWidget(type, config) { return { id: crypto.randomUUID(), type, config, position: { x: 0, y: 0 } }; }|feature,ui"
  "feat/email-templates|feat: add customizable email templates|Implemented Handlebars-based email templates with preview. Supports variables, conditionals, and loops.|src/email/templates.js|// Email template engine\nconst Handlebars = require('handlebars');\nexports.render = (template, data) => {\n  const compiled = Handlebars.compile(template);\n  return compiled(data);\n};|feature,email"
  "feat/bulk-operations|feat: add bulk select and actions|Users can now select multiple items and perform bulk actions (delete, archive, export, tag).|src/components/BulkActions.js|// Bulk actions component\nexport function BulkActions({ selected, onAction }) {\n  const actions = ['delete', 'archive', 'export', 'tag'];\n  return actions.map(a => ({ action: a, count: selected.length }));\n}|feature,ui"
  "feat/advanced-filters|feat: implement advanced filter builder|Drag-and-drop filter builder with AND/OR logic, date ranges, numeric comparisons, and saved filter presets.|src/filters/builder.js|// Filter builder\nexport function buildQuery(filters) {\n  return filters.map(f => ({\n    field: f.field, op: f.operator, value: f.value\n  }));\n}|feature,search"
  "feat/team-workspaces|feat: add multi-team workspace support|Organizations can create multiple workspaces. Each workspace has its own members, settings, and data.|src/workspace/manager.js|// Workspace manager\nexports.create = async (pool, { name, orgId, createdBy }) => {\n  const { rows } = await pool.query('INSERT INTO workspaces (name, org_id, created_by) VALUES ($1,$2,$3) RETURNING *', [name, orgId, createdBy]);\n  return rows[0];\n};|feature,teams"
  "feat/changelog-rss|feat: add RSS feed for public changelogs|Public changelogs now have an auto-generated RSS/Atom feed that users and tools can subscribe to.|src/changelog/rss.js|// RSS feed generator\nexports.generateFeed = (notes) => {\n  const items = notes.map(n => \`<item><title>\${n.title}</title><description>\${n.content}</description></item>\`);\n  return \`<?xml version='1.0'?><rss version='2.0'><channel>\${items.join('')}</channel></rss>\`;\n};|feature,changelog"
  "feat/keyboard-shortcuts|feat: add keyboard shortcuts throughout app|Global keyboard shortcuts for common actions. Cmd+K for search, Cmd+N for new note, Cmd+S for save.|src/shortcuts/manager.js|// Keyboard shortcut manager\nconst shortcuts = new Map();\nexports.register = (combo, handler) => shortcuts.set(combo, handler);\ndocument.addEventListener('keydown', (e) => {\n  const combo = [e.metaKey && 'cmd', e.key].filter(Boolean).join('+');\n  shortcuts.get(combo)?.(e);\n});|feature,ui"
  "feat/api-versioning|feat: implement API versioning|Added /v1 and /v2 API prefixes with automatic version negotiation via Accept header.|src/api/versioning.js|// API version router\nconst versions = { v1: require('./v1'), v2: require('./v2') };\nexports.route = (req) => {\n  const v = req.headers.accept?.match(/version=(v\\d+)/)?.[1] || 'v2';\n  return versions[v];\n};|feature,api"
  "feat/data-import|feat: add CSV/JSON data import wizard|Step-by-step import wizard with column mapping, validation preview, and rollback on failure.|src/import/wizard.js|// Import wizard\nexports.parseCSV = (text) => {\n  const [header, ...rows] = text.split('\\n').map(r => r.split(','));\n  return rows.map(r => Object.fromEntries(header.map((h, i) => [h.trim(), r[i]?.trim()])));\n};|feature,import"

  # Bug fixes (20)
  "fix/login-redirect|fix: resolve login redirect loop on expired sessions|Fixed infinite redirect loop when session token expires during navigation. Now properly clears stale tokens before redirecting.|src/auth/session.js|// Session handler\nexports.validateSession = (req) => {\n  if (!req.session?.valid) { req.session.destroy(); return false; }\n  return true;\n};|bug,auth"
  "fix/memory-leak-ws|fix: patch WebSocket memory leak on disconnect|Fixed memory leak where disconnected WebSocket clients were not being cleaned up. Added heartbeat ping/pong mechanism.|src/ws/heartbeat.js|// WebSocket heartbeat\nexports.startHeartbeat = (wss, interval = 30000) => {\n  setInterval(() => { wss.clients.forEach(ws => { if (!ws.isAlive) return ws.terminate(); ws.isAlive = false; ws.ping(); }); }, interval);\n};|bug,performance"
  "fix/timezone-dates|fix: correct timezone handling in date filters|Date filters were using server timezone instead of user timezone. Now passes timezone offset from client.|src/utils/dates.js|// Timezone-aware date utility\nexports.toUserTZ = (date, offsetMinutes) => {\n  const d = new Date(date);\n  d.setMinutes(d.getMinutes() + offsetMinutes);\n  return d;\n};|bug"
  "fix/pagination-offset|fix: off-by-one error in pagination|Fixed pagination returning duplicate items on page boundaries. Corrected offset calculation.|src/utils/pagination.js|// Pagination utility\nexports.paginate = (page, limit = 50) => ({\n  offset: (Math.max(1, page) - 1) * limit,\n  limit,\n});|bug"
  "fix/xss-sanitize|fix: sanitize HTML in user-generated content|Fixed XSS vulnerability in markdown preview by adding DOMPurify sanitization on all user content rendering.|src/utils/sanitize.js|// HTML sanitizer\nconst DOMPurify = require('dompurify');\nexports.clean = (html) => DOMPurify.sanitize(html, { ALLOWED_TAGS: ['b','i','a','p','br','ul','ol','li','code','pre'] });|bug,security"
  "fix/race-condition-save|fix: prevent race condition on concurrent saves|Added optimistic locking with version numbers to prevent data loss when two users edit the same document.|src/db/optimisticLock.js|// Optimistic locking\nexports.update = async (pool, table, id, data, version) => {\n  const { rowCount } = await pool.query(\`UPDATE \${table} SET data=$1, version=version+1 WHERE id=$2 AND version=$3\`, [data, id, version]);\n  if (!rowCount) throw new Error('Conflict: document was modified');\n};|bug,database"
  "fix/email-delivery|fix: retry failed email deliveries|Emails were silently failing on SMTP timeouts. Added exponential backoff retry with max 3 attempts.|src/email/retry.js|// Email retry logic\nexports.sendWithRetry = async (mailer, opts, maxRetries = 3) => {\n  for (let i = 0; i < maxRetries; i++) {\n    try { return await mailer.send(opts); }\n    catch (e) { if (i === maxRetries - 1) throw e; await new Promise(r => setTimeout(r, 1000 * 2 ** i)); }\n  }\n};|bug,email"
  "fix/mobile-overflow|fix: horizontal scroll overflow on mobile|Fixed layout breaking on mobile devices due to fixed-width table not respecting viewport constraints.|src/styles/mobile.css|/* Mobile overflow fix */\n.table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }\n.table-wrap table { min-width: 600px; }|bug,ui"
  "fix/api-error-codes|fix: return proper HTTP status codes|Several API endpoints were returning 200 with error body instead of proper 4xx/5xx status codes.|src/middleware/errorHandler.js|// Error handler\nexports.errorHandler = (err, req, res, next) => {\n  const status = err.status || 500;\n  res.status(status).json({ error: err.message, code: err.code });\n};|bug,api"
  "fix/search-encoding|fix: handle special characters in search queries|Search was failing for queries containing &, +, and #. Added proper URL encoding for search parameters.|src/search/encode.js|// Search query encoder\nexports.encodeQuery = (q) => encodeURIComponent(q).replace(/%20/g, '+');|bug,search"
  "fix/csv-unicode|fix: handle Unicode characters in CSV export|CSV export was corrupting non-ASCII characters. Added BOM header and proper UTF-8 encoding.|src/export/csvFix.js|// CSV Unicode fix\nexports.addBOM = (csv) => '\\uFEFF' + csv;|bug,export"
  "fix/session-expire|fix: graceful session expiration handling|Users were getting a blank page on session expiry. Now shows a friendly modal with re-login option.|src/auth/expireHandler.js|// Session expiry handler\nexports.onExpire = () => {\n  document.getElementById('session-modal').style.display = 'flex';\n};|bug,auth"
  "fix/duplicate-webhook|fix: prevent duplicate webhook deliveries|Race condition was causing webhooks to fire twice. Added idempotency key check before dispatch.|src/webhooks/idempotent.js|// Idempotency check\nconst sent = new Set();\nexports.shouldSend = (key) => { if (sent.has(key)) return false; sent.add(key); setTimeout(() => sent.delete(key), 300000); return true; };|bug,integrations"
  "fix/dark-mode-flash|fix: eliminate white flash on dark mode load|Page was briefly showing white background before dark mode CSS loaded. Added blocking script in head.|src/theme/noFlash.js|// Prevent dark mode flash\n(function() { if (localStorage.getItem('theme') === 'dark') document.documentElement.classList.add('dark'); })();|bug,ui"
  "fix/n-plus-one|fix: resolve N+1 query in dashboard|Dashboard was executing a separate query per item. Refactored to use a single JOIN query.|src/db/dashboardQuery.js|// Optimized dashboard query\nexports.getDashboard = (pool, userId) => pool.query(\`\n  SELECT n.*, COUNT(pe.id) as publish_count\n  FROM release_notes n LEFT JOIN publish_events pe ON pe.release_note_id = n.id\n  WHERE n.user_id = $1 GROUP BY n.id ORDER BY n.created_at DESC LIMIT 10\`, [userId]);|bug,performance,database"
  "fix/upload-timeout|fix: increase upload timeout for large files|Large file uploads were timing out at the default 30s. Increased to 5 minutes for upload endpoints only.|src/middleware/timeout.js|// Custom timeout middleware\nexports.uploadTimeout = (req, res, next) => { req.setTimeout(300000); next(); };|bug,storage"
  "fix/scroll-position|fix: restore scroll position on navigation|Browser back/forward was not restoring scroll position. Saved scroll positions in sessionStorage.|src/navigation/scroll.js|// Scroll position restore\nwindow.addEventListener('beforeunload', () => sessionStorage.setItem('scrollY', window.scrollY));\nwindow.addEventListener('load', () => { const y = sessionStorage.getItem('scrollY'); if (y) window.scrollTo(0, parseInt(y)); });|bug,ui"
  "fix/oauth-state|fix: validate OAuth state parameter|OAuth callback was not verifying the state parameter, allowing CSRF attacks. Added HMAC-based state validation.|src/auth/oauthState.js|// OAuth state validation\nconst crypto = require('crypto');\nexports.create = (userId, secret) => { const hmac = crypto.createHmac('sha256', secret).update(userId).digest('hex'); return \`\${userId}.\${hmac}\`; };\nexports.verify = (state, secret) => { const [uid, sig] = state.split('.'); return sig === crypto.createHmac('sha256', secret).update(uid).digest('hex'); };|bug,security"
  "fix/caching-headers|fix: add proper cache-control headers|Static assets were not being cached. Added Cache-Control headers for immutable assets and no-cache for API.|src/middleware/cache.js|// Cache control middleware\nexports.staticCache = (req, res, next) => { res.setHeader('Cache-Control', 'public, max-age=31536000, immutable'); next(); };\nexports.noCache = (req, res, next) => { res.setHeader('Cache-Control', 'no-store'); next(); };|bug,performance"
  "fix/dropdown-z-index|fix: dropdown menu appearing behind modals|Fixed z-index stacking context issue where dropdowns inside modals were clipped.|src/styles/zindex.css|/* Z-index fix */\n.modal { z-index: 1000; }\n.modal .dropdown { z-index: 1001; position: relative; }|bug,ui"

  # Refactoring/Chore (10)
  "refactor/db-pool|refactor: optimize database connection pooling|Replaced individual connections with a shared pool. Added connection health checks and auto-reconnect.|src/db/pool.js|// Database pool\nconst { Pool } = require('pg');\nconst pool = new Pool({ max: 20, idleTimeoutMillis: 30000, connectionTimeoutMillis: 2000 });\nmodule.exports = pool;|refactor,database"
  "chore/deps-update|chore: update dependencies to latest versions|Updated all dependencies. Major: express 4→5, react 18→19. Verified all tests pass.|package.json|{ \"dependencies\": { \"express\": \"^5.0.0\", \"react\": \"^19.0.0\", \"pg\": \"^8.13.0\" } }|chore,dependencies"
  "refactor/error-handling|refactor: centralize error handling|Moved scattered try-catch blocks to a centralized error handling middleware with consistent error response format.|src/middleware/errors.js|// Centralized error handler\nclass AppError extends Error { constructor(message, status = 500) { super(message); this.status = status; } }\nexports.AppError = AppError;\nexports.handler = (err, req, res, next) => res.status(err.status || 500).json({ error: err.message });|refactor"
  "perf/lazy-load|perf: implement lazy loading for heavy components|Added React.lazy and Suspense for dashboard charts, editor, and settings pages. Reduced initial bundle by 40%.|src/App.lazy.js|// Lazy loaded routes\nconst Dashboard = React.lazy(() => import('./pages/Dashboard'));\nconst Editor = React.lazy(() => import('./pages/Editor'));\nconst Settings = React.lazy(() => import('./pages/Settings'));|performance,ui"
  "refactor/typescript-types|refactor: add TypeScript type definitions|Added .d.ts files for all major modules. Enables better IDE support and catches type errors early.|src/types/index.d.ts|// Type definitions\nexport interface User { id: string; email: string; name: string; role: 'admin' | 'editor' | 'viewer'; }\nexport interface ReleaseNote { id: string; title: string; content: string; source: string; audience: string; createdAt: Date; }|refactor,typescript"
  "chore/ci-pipeline|chore: add GitHub Actions CI pipeline|Added automated testing, linting, and build verification on every PR. Includes coverage reporting.|.github/workflows/ci.yml|name: CI\non: [pull_request]\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n      - run: npm ci\n      - run: npm test|chore,ci"
  "refactor/api-validation|refactor: add request validation with Zod|Replaced manual validation with Zod schemas. Provides clear error messages and type inference.|src/validation/schemas.js|// Zod validation schemas\nconst { z } = require('zod');\nexports.createNoteSchema = z.object({ title: z.string().min(1).max(200), content: z.string().min(1), audience: z.enum(['developer','product','qa','executive']) });|refactor,api"
  "perf/query-optimization|perf: add database indexes for common queries|Added composite indexes on frequently queried columns. Reduced dashboard load time by 60%.|migrations/add-indexes.sql|CREATE INDEX CONCURRENTLY idx_notes_user_created ON release_notes (user_id, created_at DESC);\nCREATE INDEX CONCURRENTLY idx_usage_user_key ON usage_counters (user_id, counter_key, period_start);|performance,database"
  "docs/api-documentation|docs: add OpenAPI/Swagger documentation|Generated OpenAPI 3.0 spec from route definitions. Swagger UI available at /api/docs.|docs/openapi.yaml|openapi: '3.0.3'\ninfo:\n  title: Releaslyy API\n  version: 2.0.0\npaths:\n  /api/notes:\n    get:\n      summary: List release notes\n      security:\n        - session: []|docs,api"
  "chore/docker-setup|chore: add Docker and docker-compose setup|Added Dockerfile and docker-compose for local development. Includes PostgreSQL, Redis, and the app.|Dockerfile|FROM node:22-alpine\nWORKDIR /app\nCOPY package*.json ./\nRUN npm ci --production\nCOPY . .\nEXPOSE 3000\nCMD [\"node\", \"index.js\"]|chore,devops"
)

# Open PR definitions (10)
OPEN_PRS=(
  "feat/ai-suggestions|feat: AI-powered commit message suggestions|WIP: Using LLM to suggest better commit messages based on diff analysis.|src/ai/commitSuggest.js|// AI commit suggestions (WIP)\nexports.suggest = async (diff) => { /* TODO: implement LLM call */ };|feature,ai,wip"
  "feat/slack-threads|feat: publish to Slack threads|Allow publishing follow-up notes as thread replies to the original Slack message.|src/publish/slackThread.js|// Slack thread publishing (WIP)\nexports.replyInThread = async (channel, threadTs, text) => { /* TODO */ };|feature,integrations,wip"
  "feat/custom-domains|feat: add custom domain support for changelogs|Allow Pro users to use their own domain for public changelog pages.|src/changelog/customDomain.js|// Custom domain support (WIP)\nexports.verifyDomain = async (domain) => { /* TODO: DNS verification */ };|feature,changelog,wip"
  "feat/approval-workflow|feat: add release note approval workflow|Team leads can review and approve release notes before publishing.|src/workflow/approval.js|// Approval workflow (WIP)\nexports.requestApproval = async (noteId, reviewerId) => { /* TODO */ };|feature,teams,wip"
  "feat/analytics-dashboard|feat: add usage analytics dashboard|Visual analytics showing generation trends, popular sources, and team activity.|src/analytics/dashboard.js|// Analytics dashboard (WIP)\nexports.getStats = async (pool, orgId, range) => { /* TODO */ };|feature,analytics,wip"
  "fix/safari-clipboard|fix: clipboard API not working in Safari|Safari requires a user gesture for clipboard.writeText. Need to use execCommand fallback.|src/utils/clipboard.js|// Cross-browser clipboard (WIP)\nexports.copy = async (text) => {\n  try { await navigator.clipboard.writeText(text); }\n  catch { /* TODO: execCommand fallback */ }\n};|bug,ui,wip"
  "feat/gitlab-integration|feat: add GitLab integration|OAuth + API integration for GitLab repos, branches, MRs, and releases.|src/integrations/gitlab.js|// GitLab integration (WIP)\nconst GITLAB_API = 'https://gitlab.com/api/v4';\nexports.getMergeRequests = async (token, projectId) => { /* TODO */ };|feature,integrations,wip"
  "refactor/component-library|refactor: extract shared component library|Moving common UI components (Button, Modal, Dropdown, Toast) into a shared package.|src/components/shared/index.js|// Shared component library (WIP)\nexport { Button } from './Button';\nexport { Modal } from './Modal';\nexport { Dropdown } from './Dropdown';|refactor,ui,wip"
  "feat/bitbucket-integration|feat: add Bitbucket Cloud integration|OAuth 2.0 integration for Bitbucket repositories, branches, and pull requests.|src/integrations/bitbucket.js|// Bitbucket integration (WIP)\nconst BITBUCKET_API = 'https://api.bitbucket.org/2.0';\nexports.getRepos = async (token) => { /* TODO */ };|feature,integrations,wip"
  "feat/scheduled-releases|feat: schedule release note generation|Allow users to schedule automatic generation at the end of each sprint/cycle.|src/scheduler/releases.js|// Scheduled releases (WIP)\nexports.schedule = async (config) => { /* TODO: cron job setup */ };|feature,automation,wip"
)

echo "=== Creating 60 merged PRs ==="
for i in "${!MERGED_PRS[@]}"; do
  IFS='|' read -r branch title desc file content labels <<< "${MERGED_PRS[$i]}"
  num=$((i + 1))
  echo "[$num/60] $title"

  # Create branch, add file, push
  git checkout -q main
  git checkout -q -b "$branch" 2>/dev/null || git checkout -q "$branch"
  mkdir -p "$(dirname "$file")"
  printf "$content" > "$file"
  git add -A
  git commit -q -m "$title" -m "$desc" --allow-empty
  git push -q origin "$branch" 2>/dev/null || git push -q --set-upstream origin "$branch"

  # Create PR via API
  pr_response=$(curl -s -X POST "https://api.github.com/repos/$REPO/pulls" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$(jq -n --arg title "$title" --arg body "$desc" --arg head "$branch" --arg base "main" \
      '{title: $title, body: $body, head: $head, base: $base}')")
  pr_number=$(echo "$pr_response" | jq -r '.number')

  if [ "$pr_number" = "null" ] || [ -z "$pr_number" ]; then
    echo "  WARNING: PR creation failed - $(echo "$pr_response" | jq -r '.message // .errors[0].message // "unknown error"')"
    continue
  fi

  # Add labels
  if [ -n "$labels" ]; then
    IFS=',' read -ra label_arr <<< "$labels"
    label_json=$(printf '%s\n' "${label_arr[@]}" | jq -R . | jq -s .)
    curl -s -X POST "https://api.github.com/repos/$REPO/issues/$pr_number/labels" \
      -H "Authorization: token $TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -d "{\"labels\": $label_json}" > /dev/null
  fi

  # Merge PR
  curl -s -X PUT "https://api.github.com/repos/$REPO/pulls/$pr_number/merge" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d '{"merge_method": "squash"}' > /dev/null

  echo "  PR #$pr_number merged"
  git checkout -q main
  git pull -q origin main

  # Small delay to avoid rate limits
  sleep 0.5
done

echo ""
echo "=== Creating 10 open PRs ==="
for i in "${!OPEN_PRS[@]}"; do
  IFS='|' read -r branch title desc file content labels <<< "${OPEN_PRS[$i]}"
  num=$((i + 1))
  echo "[$num/10] $title"

  git checkout -q main
  git checkout -q -b "$branch" 2>/dev/null || git checkout -q "$branch"
  mkdir -p "$(dirname "$file")"
  printf "$content" > "$file"
  git add -A
  git commit -q -m "$title" -m "$desc" --allow-empty
  git push -q origin "$branch" 2>/dev/null || git push -q --set-upstream origin "$branch"

  pr_response=$(curl -s -X POST "https://api.github.com/repos/$REPO/pulls" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$(jq -n --arg title "$title" --arg body "$desc" --arg head "$branch" --arg base "main" \
      '{title: $title, body: $body, head: $head, base: $base}')")
  pr_number=$(echo "$pr_response" | jq -r '.number')

  if [ "$pr_number" = "null" ] || [ -z "$pr_number" ]; then
    echo "  WARNING: PR creation failed"
    continue
  fi

  if [ -n "$labels" ]; then
    IFS=',' read -ra label_arr <<< "$labels"
    label_json=$(printf '%s\n' "${label_arr[@]}" | jq -R . | jq -s .)
    curl -s -X POST "https://api.github.com/repos/$REPO/issues/$pr_number/labels" \
      -H "Authorization: token $TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -d "{\"labels\": $label_json}" > /dev/null
  fi

  echo "  PR #$pr_number opened"
  git checkout -q main
  sleep 0.3
done

echo ""
echo "=== Done! ==="
echo "Check: https://github.com/$REPO/pulls"
