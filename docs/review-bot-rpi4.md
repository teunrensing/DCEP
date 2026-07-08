# Raspberry Pi 4 local review bot

This creates a local code review flow without GitHub or GitLab.

## What it does

You push code to a bare Git repository on the Raspberry Pi. A `post-receive` hook checks out the pushed commit, runs project checks, optionally runs a review CLI, and writes a Markdown report.

```text
your laptop
  git push pi-review HEAD:refs/heads/review/my-change
      |
      v
Raspberry Pi 4
  /srv/review-bot/repos/firmware.git
      |
      v
  /srv/review-bot/reports/firmware/latest.md
```

## Security model

This is for a trusted solo workflow on your own network.

Do not expose the Pi's SSH service directly to the internet. The bot runs scripts from the pushed repository, so only push code you trust.

Recommended hardening:

- create a dedicated `reviewbot` or `git` Linux user on the Pi;
- use SSH keys, not password login;
- keep the Pi on your local network or VPN only;
- do not store AI/API credentials in the repository;
- review reports are local files, so treat `/srv/review-bot/reports` as private.

Create a dedicated user:

```bash
sudo adduser --disabled-password --gecos "" reviewbot
sudo usermod -aG dialout,plugdev reviewbot
```

Then install the repo while logged in as that user.

## Pi setup

Install basic tools on the Pi:

```bash
sudo apt-get update
sudo apt-get install -y git make python3 python3-pip python3-venv pipx clang clang-format clang-tidy clangd cppcheck doxygen graphviz
pipx install platformio
pipx ensurepath
```

Install whichever review CLI you want the bot to run. Keep its credentials in the Pi user's shell environment, a systemd user environment, or another local secret store. Do not commit credentials to the repo.

## Install the bare review repo

If you want the default `/srv/review-bot` location, create it once:

```bash
sudo mkdir -p /srv/review-bot
sudo chown -R "$USER:$USER" /srv/review-bot
```

Or use a home-directory location:

```bash
export REVIEW_BOT_HOME="$HOME/review-bot"
```

From your PlatformIO project on the Pi, run:

```bash
bash .devenvironment/review-bot/install-rpi4-review-bot.sh firmware
```

This creates:

```text
/srv/review-bot/repos/firmware.git
/srv/review-bot/worktrees/firmware/
/srv/review-bot/reports/firmware/
/srv/review-bot/locks/
```

It also installs a Git `post-receive` hook into the bare repo.

## Add the Pi remote

From your normal development machine:

```bash
git remote add pi-review pi@raspberrypi.local:/srv/review-bot/repos/firmware.git
git push pi-review HEAD:refs/heads/review/my-change
```

Use your Pi hostname or IP address instead of `raspberrypi.local` if needed.

## Configure checks

The default `.reviewbot/checks.sh` runs:

```bash
make build
make check
make test-native
```

`make test-native` is skipped automatically if the `native` PlatformIO environment is not configured.

Edit `.reviewbot/checks.sh` for your preferred local workflow.

## Configure the review CLI

Copy the example file:

```bash
cp .reviewbot/review-command.example.sh .reviewbot/review-command.sh
chmod +x .reviewbot/review-command.sh
```

Then edit `.reviewbot/review-command.sh` to call your review CLI.

The bot provides these environment variables to the script:

```text
REVIEW_REPO_DIR      bare Git repository path
REVIEW_WORKTREE     checked-out project path
REVIEW_OLD_REV      previous revision
REVIEW_NEW_REV      pushed revision
REVIEW_REF_NAME     pushed Git ref
REVIEW_BRANCH       branch name
REVIEW_DIFF_FILE    diff file to review
REVIEW_REPORT_FILE  Markdown report file to append to
```

The script should append its review to `REVIEW_REPORT_FILE`.

## Read reports

On the Pi:

```bash
less /srv/review-bot/reports/firmware/latest.md
```

Or copy the report back:

```bash
scp pi@raspberrypi.local:/srv/review-bot/reports/firmware/latest.md .
```

## Optional local web view

On the Pi:

```bash
cd /srv/review-bot/reports/firmware
python3 -m http.server 8091
```

Then open:

```text
http://raspberrypi.local:8091/latest.md
```

Keep this on your local network only.

## Cleanup

Review runs are serialized with a lock so two pushes do not build in the same worktree at the same time.

Clean old reports and temporary worktrees:

```bash
/srv/review-bot/bin/cleanup-review-bot.sh firmware 30
```

Optional cron entry:

```cron
15 3 * * * /srv/review-bot/bin/cleanup-review-bot.sh firmware 30 >/dev/null 2>&1
```
