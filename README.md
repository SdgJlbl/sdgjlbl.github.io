# SdgJlbl's blog

## Serve locally

- `docker compose up --build`
- Head to http://127.0.0.1:4000
- Auto-reload is enabled, so the page should reload after a file save (after about 4s).

## Update dependencies

- `docker compose run --rm jekyll bundle update`
- `git add Gemfile.lock`
- `git commit -m "deps" && git push origin master`
