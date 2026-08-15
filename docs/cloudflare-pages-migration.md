# Cloudflare Pages Migration

This site is now set up to be exported as a static archive and hosted on Cloudflare Pages. Rails remains the local generator for public HTML and JSON, but Cloudflare Pages serves production after cutover.

## Stack

- Public hosting: Cloudflare Pages.
- Dynamic runtime after cutover: none.
- Images: existing S3 bucket and CloudFront image resizing URLs.
- Search: existing browser-side Algolia integration plus generated `/autocomplete.json`.
- Source of truth for future regeneration: the sanitized committed database archive in `db/archive/`.

## Local prerequisites

Use the app's pinned legacy runtime versions. The current asset stack uses `node-sass@4.13.0`, so newer Node versions are not reliable with the checked-in lockfile.

```sh
rbenv install 2.7.6
rbenv local 2.7.6
gem install bundler:2.1.4
brew install shared-mime-info libffi
bundle config set --local build.nio4r "--with-cflags=-Wno-error=incompatible-function-pointer-types"
bundle config set --local build.ffi "--enable-system-libffi --with-ffi-dir=$(brew --prefix libffi)"
PKG_CONFIG_PATH="$(brew --prefix libffi)/lib/pkgconfig" bundle _2.1.4_ install

volta install node@12.22.12 npm@6.14.16
npm ci
```

Install Postgres client tools if `createdb`, `dropdb`, or `pg_restore` are missing.

## Restore archived source data

For routine regeneration after Heroku is retired, restore the committed sanitized archive:

```sh
dropdb tuxedo_static --if-exists
createdb tuxedo_static
pg_restore --no-acl --no-owner -d tuxedo_static db/archive/tuxedo-static-source-2026-08-14.sanitized.dump
```

Check the archive docs and table counts:

```sh
shasum -a 256 -c db/archive/SHA256SUMS
cat db/archive/table-counts.csv
wc -l db/archive/image-keys.txt
```

## Export production data from Heroku

This path is only needed while Heroku still exists or if you want one final fresh backup before deleting Heroku.

Capture and download a fresh Heroku database backup.

```sh
heroku pg:backups:capture -a <HEROKU_APP>
heroku pg:backups:download -a <HEROKU_APP> -o latest.dump
```

Restore the dump into a local export database. Review and sanitize user/runtime-only data before committing any new archive dump.

```sh
dropdb tuxedo_static --if-exists
createdb tuxedo_static
pg_restore --verbose --clean --if-exists --no-acl --no-owner -d tuxedo_static latest.dump
```

Build assets and export the static site.

```sh
npm run build
DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:export
```

The export writes to `static_dist/`. This directory is intentionally ignored by git. The database archive in `db/archive/` is intentionally committed; raw local Heroku dumps such as `latest.dump` remain ignored.

Useful variants:

```sh
DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:routes
DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:validate
OUTPUT_DIR=tmp/static_dist DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:export
STATIC_EXPORT_HOST=www.tuxedono2.com DATABASE_URL=postgres:///tuxedo_static RAILS_ENV=production bundle exec rake static:export
```

## What the exporter generates

- Clean URL HTML files for `/`, `/about`, `/site-index`, `/recipes`, `/ingredients`, letter indexes, recipes, ingredients, and tags.
- The legacy Rails `/index` page is exported as `/site-index` because static hosts reserve root `index.html` for `/`.
- Static fragments for existing lazy loading:
  - `/index/more/:page`
  - `/ingredients/:id/recents/:page`
- `/autocomplete.json` for the public search input.
- `_redirects` for deprecated list URLs and retired admin/edit routes.
- `_headers` with conservative static asset cache headers.
- `static-export-manifest.json` with rendered routes and redirects.

The exporter removes hidden admin/edit header links from generated HTML. Devise, admin writes, S3 upload-token generation, and SendGrid mailer routes are not exported.

The database archive preserves image object keys, but not image binaries. S3/CloudFront remains part of the hosting stack. If you ever plan to delete the S3 bucket, back up those image objects separately first.

## Deploy to Cloudflare Pages

Create a Cloudflare Pages project for direct uploads. Either upload `static_dist/` in the Cloudflare dashboard or use Wrangler from a modern Node shell. The project itself pins Node 12 for legacy asset builds, so do not run modern Wrangler through the repo's Volta-managed Node runtime.

```sh
npx wrangler pages deploy static_dist --project-name=tuxedo-no2
```

Verify the `*.pages.dev` preview before assigning production domains.

## Verification checklist

Run after export and again after Cloudflare preview deploy:

- `bundle exec rake static:validate` passes with `DATABASE_URL` and `RAILS_ENV=production` set.
- File count is below the Cloudflare Pages Free limit of 20,000 files.
- Visit `/`, `/recipes`, `/ingredients`, `/index`, `/about`, several recipe pages, several ingredient pages, and several tag pages.
- Test homepage lazy loading and ingredient "Recent Additions" loading.
- Test search autocomplete and the Algolia full-text modal.
- Test deprecated redirects such as `/list/fall-cocktails-cocktail-recipes`.
- Confirm `/admin`, `/users/sign_in`, `/new`, and edit/delete URLs do not expose a live admin workflow.
- Confirm S3/CloudFront images, `/dist/application.css`, `/dist/application.js`, `/dist/sprite.svg`, fonts, `robots.txt`, favicon, and social images load.
- Confirm HTTPS works on the Pages preview.

## Cutover and rollback

1. Add `tuxedono2.com` and `www.tuxedono2.com` as custom domains on the Cloudflare Pages project.
2. Update Cloudflare DNS/routing from Heroku to Pages.
3. Keep Heroku running for 7 days.
4. If rollback is needed, point Cloudflare DNS/routing back to Heroku.
5. After the hold period, confirm `db/archive/` is committed and restorable, optionally download one final raw database backup for private storage, then scale down or delete the Heroku app/database.
