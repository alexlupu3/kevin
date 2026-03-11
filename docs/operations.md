# Operations

## Install Kevin

Run the full bootstrap from the repository root:

```bash
sudo KEVIN_PUBKEY_FILE=/path/to/kevin.pub KEVIN_INSTALL_CLI=y bash bootstrap/99-bootstrap-all.sh
```

## Update One Tool

Edit the source file in `tools/` and rerun its installer. Example:

```bash
sudo bash bootstrap/20-install-server-update.sh
```

To deploy the new site disable tool:

```bash
sudo bash bootstrap/35-install-project-disable.sh
```

To deploy the new site enable and delete tools:

```bash
sudo bash bootstrap/36-install-project-enable.sh
sudo bash bootstrap/37-install-project-delete.sh
```

To deploy the project deployment tool:

```bash
sudo bash bootstrap/34-install-project-deploy.sh
```

To deploy the help and project listing tools:

```bash
sudo bash bootstrap/15-install-help.sh
sudo bash bootstrap/32-install-project-list.sh
```

## Rerun Full Bootstrap

The bootstrap scripts are intended to be idempotent:

```bash
sudo KEVIN_INSTALL_CLI=y bash bootstrap/99-bootstrap-all.sh
```

## Check Kevin's Sudo Access

```bash
sudo -l -U kevin
sudo -u kevin sudo -l
sudo -u kevin kevin help
kevin project-list
sudo -u kevin kevin server-check
```

## List Kevin Commands

```bash
sudo kevin help
```

## Test Project Creation

```bash
sudo kevin project-create testapp
```

Then validate:

```bash
sudo nginx -t
test -d /opt/kevin/staging/testapp
curl -I https://testapp.alexlupu.dev
```

## Test Project Deploy

Direct `rsync` into `/var/www/<project>/public` is not supported. Stage files under `/opt/kevin/staging/<project>/` and deploy with Kevin:

```bash
sudo -u kevin rsync -av ./build/ /opt/kevin/staging/testapp/
sudo kevin project-deploy testapp
test -f /var/log/kevin/project-deploy.log
find /var/www/testapp/public -printf '%M %u:%g %p\n' | head
```

## Test Project List

```bash
kevin project-list
```

## Test Project Disable

```bash
sudo kevin project-disable testapp
sudo nginx -t
ls -l /etc/nginx/sites-available/testapp.alexlupu.dev
test ! -L /etc/nginx/sites-enabled/testapp.alexlupu.dev
```

## Test Project Enable

```bash
sudo kevin project-enable testapp
sudo nginx -t
test -L /etc/nginx/sites-enabled/testapp.alexlupu.dev
```

## Test Project Delete

```bash
sudo kevin project-delete testapp --force
sudo nginx -t
test ! -e /etc/nginx/sites-available/testapp.alexlupu.dev
test ! -e /etc/nginx/sites-enabled/testapp.alexlupu.dev
test ! -d /var/www/testapp
```

## Inspect Logs

```bash
sudo ls -lah /var/log/kevin
sudo tail -n 100 /var/log/kevin/project-deploy.log
sudo tail -n 100 /var/log/kevin/server-update.log
sudo tail -n 100 /var/log/kevin/server-vuln-scan-*.log
```
