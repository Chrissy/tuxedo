# Static Site Preservation Notes

Tuxedo No.2 now treats Rails as a local static-site generator and Cloudflare Pages as the production host. Heroku is no longer needed after cutover and rollback hold.

## Current Source Of Truth

- Content source: `db/archive/tuxedo-static-source-2026-08-14.sanitized.dump`.
- Portable fallback: `db/archive/tuxedo-static-source-2026-08-14.sanitized.sql`.
- Generated site output: `static_dist/`, intentionally ignored by git.
- Image assets: existing S3 bucket and CloudFront image resizing URLs referenced by the database. The expected object keys are committed in `db/archive/image-keys.txt`.

## Regeneration Path

1. Restore `db/archive/tuxedo-static-source-2026-08-14.sanitized.dump` into a local Postgres database named `tuxedo_static`.
2. Install the legacy runtime from `docs/cloudflare-pages-migration.md`.
3. Run `npm run build`.
4. Run `DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:export`.
5. QA `static_dist/` locally with Cloudflare Pages dev or upload it to Cloudflare Pages Direct Upload.

## Important Decisions

- The committed archive is sanitized. Devise `users` rows were removed because they are not needed for static generation and include emails/password hashes/sign-in metadata.
- `delayed_jobs` rows were removed because background mail jobs are not part of the static site.
- The full A-Z index moved from `/index` to `/site-index` in the static site because static hosts reserve `index.html` for `/`; Cloudflare Pages canonicalizes `/index` to `/`.
- Mailing-list cards were removed from public pages because the site is now maintained as an archive, not an active publication.
- The image bytes are not committed to git. If the S3 bucket is ever going away, back it up separately before deleting AWS resources.

## If Future Content Edits Are Needed

Use the archive dump to restore locally, make edits through Rails locally or directly in the database with care, regenerate both:

- a new sanitized `db/archive/*.dump`
- a new sanitized `db/archive/*.sql`

Update `db/archive/SHA256SUMS`, `db/archive/table-counts.csv`, and this notes file with the new archive date.
