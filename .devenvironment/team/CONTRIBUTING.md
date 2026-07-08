# Contributing

## Local checks

Run these before sharing changes:

```bash
make compiledb
make build
make check
make tidy
make docs
```

## Commit messages

Use conventional commits:

```text
feat(sensor): add oversampling mode
fix(serial): handle empty frames
docs: document debug wiring
chore: update PlatformIO dependencies
```

## Architecture decisions

Use `docs/adr/0001-record-architecture-decisions.md` when a hardware, architecture, timing, protocol, or data-format decision should be preserved.

