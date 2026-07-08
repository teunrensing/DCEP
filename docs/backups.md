# Solo developer backups

For a solo project, backups are more important than process.

The included command creates:

- a Git bundle with all refs, if the project is a Git repository;
- a compressed worktree archive excluding generated build/report folders.

Run:

```bash
make backup
```

By default, output goes to `backups/`, which is ignored by Git.

You can write to an external drive:

```bash
make backup BACKUP_DIR=/media/$USER/USB/firmware-backups
```

For serious long-term backups, consider `restic` or `borg` to a USB drive, NAS, or another machine.

