# Deploy AntiBot to SMB Share

AntiBot can be copied to the SMB share for backup or to run from another machine.

**Share:** `smb://192.168.12.113/e/antibot`  
**Mount path (Linux):** `/run/user/1000/gvfs/smb-share:server=192.168.12.113,share=e/antibot`

## Copy to SMB

```bash
# Exclude node_modules (run pnpm install on target)
rsync -av --no-perms --no-owner --exclude 'node_modules' --exclude '.git' \
  /home/koss/antibot/ "/run/user/1000/gvfs/smb-share:server=192.168.12.113,share=e/antibot/"
```

**Note:** SMB may not support all rsync operations (permissions, atomic renames). Use `--no-perms --no-owner` if you see "Operation not supported" errors.

## On Target Machine

1. Mount the SMB share (or access via network path)
2. `cd antibot && pnpm install && pnpm build`
3. Copy or create `~/.antibot/antibot.json` (workspace path may need adjustment)
4. Run `./scripts/antibot-local` or `ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs gateway --port 18789`

## Config Note

The workspace in `~/.antibot/antibot.json` is `/home/koss/antibot`. If running from the SMB path on another machine, update the workspace path in config to match the mount location.
