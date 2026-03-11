# Operations

## Install Kevin

Run the full bootstrap from the repository root:

```bash
sudo KEVIN_PUBKEY_FILE=/path/to/kevin.pub bash bootstrap/99-bootstrap-all.sh
```

## Update One Tool

Edit the source file in `tools/` and rerun its installer. Example:

```bash
sudo bash bootstrap/20-install-server-update.sh
```

## Rerun Full Bootstrap

The bootstrap scripts are intended to be idempotent:

```bash
sudo bash bootstrap/99-bootstrap-all.sh
```

## Check Kevin's Sudo Access

```bash
sudo -l -U kevin
sudo -u kevin sudo -l
```

## Test Project Creation

```bash
sudo -u kevin sudo /opt/kevin/bin/project-create testapp
```

Then validate:

```bash
sudo nginx -t
curl -I https://testapp.alexlupu.dev
```

## Inspect Logs

```bash
sudo ls -lah /var/log/kevin
sudo tail -n 100 /var/log/kevin/server-update.log
sudo tail -n 100 /var/log/kevin/server-vuln-scan-*.log
```
