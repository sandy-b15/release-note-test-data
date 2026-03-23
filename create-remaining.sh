#!/bin/bash
set -e
cd /Users/sandy/Documents/REPO/release-note-test-data

REPO="sandy-b15/release-note-test-data"
TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill | grep "^password=" | cut -d= -f2)

create_pr() {
  local branch="$1" title="$2" body="$3" file="$4" content="$5" merge="$6"

  git checkout -q main
  git pull -q origin main 2>/dev/null || true
  git branch -D "$branch" 2>/dev/null || true
  git checkout -q -b "$branch"
  mkdir -p "$(dirname "$file")"
  echo "$content" > "$file"
  git add -A
  git commit -q -m "$title" -m "$body" --allow-empty
  git push -q --force origin "$branch" 2>/dev/null

  local pr_num
  pr_num=$(curl -s -X POST "https://api.github.com/repos/$REPO/pulls" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$(jq -n --arg t "$title" --arg b "$body" --arg h "$branch" '{title:$t,body:$b,head:$h,base:"main"}')" | jq -r '.number')

  if [ "$pr_num" = "null" ] || [ -z "$pr_num" ]; then
    echo "  SKIP (already exists or error)"
    git checkout -q main
    return
  fi

  if [ "$merge" = "yes" ]; then
    sleep 0.3
    curl -s -X PUT "https://api.github.com/repos/$REPO/pulls/$pr_num/merge" \
      -H "Authorization: token $TOKEN" -d '{"merge_method":"squash"}' > /dev/null
    echo "  #$pr_num merged"
  else
    echo "  #$pr_num opened"
  fi
  git checkout -q main
  sleep 0.5
}

echo "=== Remaining merged PRs (30-60) ==="

create_pr "fix/search-encoding" "fix: handle special characters in search queries" "Search was failing for queries with &, +, #. Added proper URL encoding." "src/search/encode.js" "exports.encodeQuery = (q) => encodeURIComponent(q);" "yes"

create_pr "fix/csv-unicode" "fix: handle Unicode characters in CSV export" "CSV export was corrupting non-ASCII chars. Added BOM header and UTF-8 encoding." "src/export/csvFix.js" "exports.addBOM = (csv) => '\uFEFF' + csv;" "yes"

create_pr "fix/session-expire" "fix: graceful session expiration handling" "Users were getting blank page on session expiry. Shows friendly re-login modal." "src/auth/expireHandler.js" "exports.onExpire = () => { document.getElementById('session-modal').style.display = 'flex'; };" "yes"

create_pr "fix/duplicate-webhook" "fix: prevent duplicate webhook deliveries" "Race condition was causing webhooks to fire twice. Added idempotency key check." "src/webhooks/idempotent.js" "const sent = new Set(); exports.shouldSend = (key) => { if (sent.has(key)) return false; sent.add(key); return true; };" "yes"

create_pr "fix/dark-mode-flash" "fix: eliminate white flash on dark mode load" "Page showed white background before dark mode CSS loaded. Added blocking script." "src/theme/noFlash.js" "if (localStorage.getItem('theme') === 'dark') document.documentElement.classList.add('dark');" "yes"

create_pr "fix/n-plus-one" "fix: resolve N+1 query in dashboard" "Dashboard was executing separate query per item. Refactored to single JOIN query." "src/db/dashboardQuery.js" "exports.getDashboard = (pool, userId) => pool.query('SELECT n.* FROM release_notes n WHERE n.user_id = $1 LIMIT 10', [userId]);" "yes"

create_pr "fix/upload-timeout" "fix: increase upload timeout for large files" "Large file uploads timing out at 30s. Increased to 5 minutes for upload endpoints." "src/middleware/timeout.js" "exports.uploadTimeout = (req, res, next) => { req.setTimeout(300000); next(); };" "yes"

create_pr "fix/scroll-position" "fix: restore scroll position on navigation" "Browser back/forward not restoring scroll position. Saved in sessionStorage." "src/navigation/scroll.js" "window.addEventListener('beforeunload', () => sessionStorage.setItem('scrollY', window.scrollY));" "yes"

create_pr "fix/oauth-state" "fix: validate OAuth state parameter" "OAuth callback not verifying state param, allowing CSRF. Added HMAC-based validation." "src/auth/oauthState.js" "const crypto = require('crypto'); exports.create = (uid, secret) => crypto.createHmac('sha256', secret).update(uid).digest('hex');" "yes"

create_pr "fix/caching-headers" "fix: add proper cache-control headers" "Static assets not being cached. Added Cache-Control for immutable assets." "src/middleware/cache.js" "exports.staticCache = (req, res, next) => { res.setHeader('Cache-Control', 'public, max-age=31536000, immutable'); next(); };" "yes"

create_pr "fix/dropdown-z-index" "fix: dropdown menu appearing behind modals" "Fixed z-index stacking context issue where dropdowns inside modals were clipped." "src/styles/zindex.css" ".modal { z-index: 1000; } .modal .dropdown { z-index: 1001; }" "yes"

create_pr "refactor/db-pool" "refactor: optimize database connection pooling" "Replaced individual connections with shared pool. Added health checks and auto-reconnect." "src/db/pool.js" "const { Pool } = require('pg'); const pool = new Pool({ max: 20 }); module.exports = pool;" "yes"

create_pr "chore/deps-update" "chore: update dependencies to latest versions" "Updated all deps. Major: express 4 to 5, react 18 to 19. All tests pass." "src/deps-log.txt" "express: 4.x -> 5.x\nreact: 18.x -> 19.x\npg: 8.11 -> 8.13" "yes"

create_pr "refactor/error-handling" "refactor: centralize error handling" "Moved scattered try-catch to centralized error middleware with consistent format." "src/middleware/errors.js" "class AppError extends Error { constructor(msg, status=500) { super(msg); this.status=status; } } module.exports = { AppError };" "yes"

create_pr "perf/lazy-load" "perf: implement lazy loading for heavy components" "Added React.lazy and Suspense for dashboard, editor, settings. Reduced bundle 40%." "src/App.lazy.js" "const Dashboard = React.lazy(() => import('./pages/Dashboard'));" "yes"

create_pr "refactor/typescript-types" "refactor: add TypeScript type definitions" "Added .d.ts files for major modules. Better IDE support and early error catching." "src/types/index.d.ts" "export interface User { id: string; email: string; name: string; }" "yes"

create_pr "chore/ci-pipeline" "chore: add GitHub Actions CI pipeline" "Automated testing, linting, build verification on every PR with coverage reporting." ".github/workflows/ci.yml" "name: CI\non: [pull_request]\njobs:\n  test:\n    runs-on: ubuntu-latest" "yes"

create_pr "refactor/api-validation" "refactor: add request validation with Zod" "Replaced manual validation with Zod schemas. Clear errors and type inference." "src/validation/schemas.js" "const { z } = require('zod'); exports.createNote = z.object({ title: z.string().min(1) });" "yes"

create_pr "perf/query-optimization" "perf: add database indexes for common queries" "Added composite indexes on frequently queried columns. Dashboard load 60% faster." "migrations/add-indexes.sql" "CREATE INDEX idx_notes_user ON release_notes (user_id, created_at DESC);" "yes"

create_pr "docs/api-documentation" "docs: add OpenAPI/Swagger documentation" "Generated OpenAPI 3.0 spec. Swagger UI available at /api/docs." "docs/openapi.yaml" "openapi: 3.0.3\ninfo:\n  title: Releaslyy API\n  version: 2.0.0" "yes"

create_pr "chore/docker-setup" "chore: add Docker and docker-compose setup" "Added Dockerfile and docker-compose for local dev. Includes PostgreSQL and Redis." "Dockerfile" "FROM node:22-alpine\nWORKDIR /app\nCOPY . .\nEXPOSE 3000\nCMD [\"node\",\"index.js\"]" "yes"

create_pr "feat/markdown-preview" "feat: add live markdown preview panel" "Side-by-side markdown editor with live preview. Supports GFM and syntax highlighting." "src/editor/preview.js" "exports.renderMarkdown = (md) => marked.parse(md);" "yes"

create_pr "feat/template-library" "feat: add release note template library" "Pre-built templates for different audiences. Users can save and share custom templates." "src/templates/library.js" "exports.getTemplates = () => [{ name: 'Engineering', audience: 'developer' }];" "yes"

create_pr "feat/diff-viewer" "feat: add visual diff viewer for note edits" "Side-by-side diff view showing changes between note versions with syntax highlighting." "src/editor/diff.js" "exports.computeDiff = (a, b) => { /* diff algorithm */ };" "yes"

create_pr "feat/batch-generate" "feat: batch generate notes for multiple sprints" "Select multiple sprints/cycles and generate combined release notes in one click." "src/generate/batch.js" "exports.batchGenerate = async (sprints, config) => { /* batch logic */ };" "yes"

create_pr "feat/comment-threads" "feat: add inline comment threads on notes" "Team members can leave comments on specific sections. Supports threads and mentions." "src/comments/threads.js" "exports.addComment = async (noteId, section, text, userId) => { /* comment logic */ };" "yes"

create_pr "fix/image-resize" "fix: auto-resize pasted images in editor" "Large pasted images were overflowing editor. Now auto-resized to max-width." "src/editor/imageResize.js" "exports.resizeImage = (img, maxWidth=800) => { /* resize logic */ };" "yes"

create_pr "feat/version-history" "feat: add version history for release notes" "Every save creates a version. Users can view history, compare versions, and restore." "src/notes/history.js" "exports.saveVersion = async (pool, noteId, content) => { /* version save */ };" "yes"

create_pr "feat/pdf-export" "feat: add PDF export with custom styling" "Export notes as styled PDF with company logo, header, footer, and table of contents." "src/export/pdf.js" "exports.toPDF = async (html, options) => { /* pdf generation */ };" "yes"

create_pr "feat/slack-bot" "feat: add Slack bot for on-demand generation" "Slack slash command /releaslyy to generate notes directly from Slack." "src/integrations/slackBot.js" "exports.handleCommand = async (payload) => { /* slash command */ };" "yes"

echo ""
echo "=== Creating 10 open PRs ==="

create_pr "feat/ai-suggestions" "feat: AI-powered commit message suggestions" "WIP: Using LLM to suggest better commit messages based on diff analysis." "src/ai/commitSuggest.js" "exports.suggest = async (diff) => { /* TODO */ };" "no"

create_pr "feat/slack-threads" "feat: publish to Slack threads" "WIP: Allow publishing follow-up notes as thread replies to original message." "src/publish/slackThread.js" "exports.replyInThread = async (channel, ts, text) => { /* TODO */ };" "no"

create_pr "feat/custom-domains" "feat: add custom domain support for changelogs" "WIP: Allow Pro users to use their own domain for public changelog pages." "src/changelog/customDomain.js" "exports.verifyDomain = async (domain) => { /* TODO */ };" "no"

create_pr "feat/approval-workflow" "feat: add release note approval workflow" "WIP: Team leads can review and approve notes before publishing." "src/workflow/approval.js" "exports.requestApproval = async (noteId, reviewerId) => { /* TODO */ };" "no"

create_pr "feat/analytics-dashboard" "feat: add usage analytics dashboard" "WIP: Visual analytics showing generation trends and team activity." "src/analytics/dashboard.js" "exports.getStats = async (pool, orgId) => { /* TODO */ };" "no"

create_pr "fix/safari-clipboard" "fix: clipboard API not working in Safari" "WIP: Safari needs execCommand fallback for clipboard.writeText." "src/utils/clipboard.js" "exports.copy = async (text) => { /* TODO: Safari fallback */ };" "no"

create_pr "feat/gitlab-integration" "feat: add GitLab integration" "WIP: OAuth + API integration for GitLab repos, branches, MRs." "src/integrations/gitlab.js" "const GITLAB_API = 'https://gitlab.com/api/v4';" "no"

create_pr "refactor/component-library" "refactor: extract shared component library" "WIP: Moving common UI components into shared package." "src/components/shared/index.js" "export { Button } from './Button';" "no"

create_pr "feat/bitbucket-integration" "feat: add Bitbucket Cloud integration" "WIP: OAuth 2.0 integration for Bitbucket repos and pull requests." "src/integrations/bitbucket.js" "const BITBUCKET_API = 'https://api.bitbucket.org/2.0';" "no"

create_pr "feat/scheduled-releases" "feat: schedule release note generation" "WIP: Schedule automatic generation at end of each sprint." "src/scheduler/releases.js" "exports.schedule = async (config) => { /* TODO: cron */ };" "no"

echo ""
echo "=== Done! ==="
git checkout -q main
