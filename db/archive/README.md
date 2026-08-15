# Static Source Data Archive

This directory contains the committed database snapshot used to regenerate the static Tuxedo No.2 site after Heroku is retired.

## Files

- `tuxedo-static-source-2026-08-14.sanitized.dump`: Postgres custom-format dump. Prefer this for restores.
- `tuxedo-static-source-2026-08-14.sanitized.sql`: Plain SQL fallback for portability and inspection.
- `table-counts.csv`: Expected table counts after restoring the sanitized archive.
- `image-keys.txt`: S3 object keys referenced by the archived database content.
- `SHA256SUMS`: Checksums for corruption checks.

## Sanitization

The archive was created from a Heroku Postgres backup and then sanitized before committing:

- `users` rows were removed. The static site does not need Devise users, password hashes, emails, or sign-in IP metadata.
- `delayed_jobs` rows were removed. Background jobs are not part of the static site.
- Recipe, ingredient/component, subcomponent, relationship, tag, and tagging data were preserved.
- Image binaries are not committed here. They remain in the existing S3/CloudFront image pipeline; `image-keys.txt` records the expected object keys.

The raw Heroku backup remains a local ignored file when present as `latest.dump`; do not commit raw production dumps without reviewing user/admin data first.

## Restore

```sh
dropdb tuxedo_static --if-exists
createdb tuxedo_static
pg_restore --no-acl --no-owner -d tuxedo_static db/archive/tuxedo-static-source-2026-08-14.sanitized.dump
```

For this committed sanitized dump, restore into a fresh database with the default `public` schema present.

## Verify

```sh
shasum -a 256 -c db/archive/SHA256SUMS
psql tuxedo_static -c "select count(*) from recipes;"
```

Then regenerate the static site:

```sh
npm run build
DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:export
```
