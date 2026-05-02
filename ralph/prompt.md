# ISSUES

GitHub issues are provided at the start of context. Parse them to understand the open issues.

You will work on the **AFK issues only** — issues explicitly marked `[HITL]` (like Slice 8: Deploy to Fly.io) are off-limits. Skip any issue that requires a human account, secret, or manual deploy step.

You've also been passed the last few git commits. Review these to understand what work has already been done.

If all AFK tasks are complete, output `<promise>NO MORE TASKS</promise>`.

---

# TASK SELECTION

Pick the next task. Respect the **Blocked by** dependencies — do not start a slice if its blocker is not yet merged. Prioritize in this order:

1. **Critical bugfixes** — anything broken that blocks other slices
2. **Development infrastructure** — migrations, model validations, test helpers, routing skeleton. Getting these right is a precursor to everything else.
3. **Tracer bullets** — the smallest end-to-end slice of a feature that touches all layers (model → controller → view → test). Validate the architecture before expanding.
4. **Polish and quick wins**
5. **Refactors**

---

# EXPLORATION

Explore the repo before writing any code:

- Read `config/routes.rb`, `app/models/`, `app/controllers/`, `db/schema.rb` (if it exists), and `test/` to understand what already exists.
- Check the `Gemfile` to know which gems are already present before adding new ones.
- Read existing tests to understand the project's testing conventions.

---

# IMPLEMENTATION

Use `/tdd` to complete the task.

**Stack context:**
- Rails 8.1, SQLite, Minitest (no RSpec)
- ERB views + Turbo (Hotwire) — no React or Vue
- Tailwind CSS via `tailwindcss-rails`
- Plain Ruby service objects in `app/services/`
- No Sorbet/RBS — Ruby is untyped here

**Rails conventions to follow:**
- Migrations via `bin/rails generate migration` or write them directly in `db/migrate/`
- Run `bin/rails db:migrate` after creating migrations
- Request tests live in `test/controllers/` using `ActionDispatch::IntegrationTest`
- Model unit tests live in `test/models/`
- Service object tests live in `test/services/`
- Stub external HTTP with `Net::HTTP` mocking or `WebMock` — no real network calls in tests
- Use `assert_response`, `assert_difference`, `assert_redirected_to` — standard Minitest Rails helpers

---

# FEEDBACK LOOPS

Before committing, run both feedback loops and fix any failures:

```bash
bin/rails test          # full test suite
bin/rubocop --autocorrect  # lint + auto-fix style issues
```

If `bin/rails test` fails, fix the tests before committing. Do not commit a red suite.

---

# COMMIT

Make a git commit. The commit message must include:

1. What was built (the slice name and key decisions)
2. Files changed (models, controllers, migrations, tests)
3. Any blockers or notes for the next iteration

Format:
```
feat: Slice N — <short description>

- Key decision or approach taken
- Files: app/models/foo.rb, db/migrate/..., test/models/foo_test.rb
- Notes: <anything the next agent should know>
```

---

# THE ISSUE

After committing:

- If the task is **complete**, post a comment on the GitHub issue using:
  ```bash
  gh issue comment <number> --body "Done — implemented in <commit sha>."
  gh issue close <number>
  ```
- If the task is **not complete**, post a comment on the GitHub issue with what was done and what remains:
  ```bash
  gh issue comment <number> --body "Partial: <what was done>. Remaining: <what is left>."
  ```

---

# FINAL RULES

- **Work on exactly one task per run.** Do not attempt multiple slices in a single session.
- Never skip the feedback loops.
- Never commit a failing test suite.
- Never work on a HITL issue.
