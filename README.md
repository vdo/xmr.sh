# xmr.sh

**xmr.sh** script wizard sets up a new server running a monero node daemon with Docker compose, with your choice of SSL certificates for your domain, network selection, a Tor hidden service, Grafana dashboard and more.

## Getting Started

The most important files are:

* `.env` - where your configurations/secrets are kept
* `docker-compose.yml` - where your Docker container options are defined

This repo provides example files for you to copy and modify to suit your deployment needs. To get started, simply copy those files and modify as needed.

```bash
# Update configurations/secrets/settings
cp env-example .env
vim .env

# Update Docker containers - uncomment services to run additional helpers
cp docker-compose-example.yml docker-compose.yml
vim docker-compose.yml
```

Once those files are present, use `docker-compose` to launch your containers.

```bash
docker-compose up -d  # start and daemonize (background) all containers

docker-compose logs -f  # tail all logs

docker-compose logs -f monerod  # tail individual container logs (here monerod)

docker-compose down  # stop containers
```

## Distribution support

Compatible and tested on:

- Debian 11
- Ubuntu Focal
- Fedora 36

Other distributions with docker pre-installed would probably be compatible as well.

## Demo

[![asciicast](https://asciinema.org/a/1gL7tNhb3XgPUr26losgZaeCJ.svg)](https://asciinema.org/a/1gL7tNhb3XgPUr26losgZaeCJ)

## FAQ

Check the [wiki](https://github.com/vdo/xmr.sh/wiki/FAQ)

## ToDo

- [x] Add wizard for DNS domain selection.
- [x] Status and node info at finish.
- [x] Mainnet / Stagenet / Testnet selection
- [x] Pruning enabled
- [x] Clearnet TLS port selection
- [x] Uninstall script
- [x] Make tor service optional
- [x] Block explorer (disabled)
- [x] Grafana dashboard
- [x] arm64 support for all images
- [x] monerod-lws support (experimental)
- [ ] Shellcheck via Github Actions
- [ ] Documentation
- [ ] monerod-proxy support for random node forwarding
- [ ] i2p service
- [ ] p2pool mining

# Credits

[@cirocosta](https://github.com/cirocosta) for the metrics exporter and grafana dashboard.

[@sethforprivacy](https://github.com/sethforprivacy) for providing and maintaining Monero Docker images.

# Donate XMR 🍕

86GwmtuKWtjJBWT8Srn4oqZHbP41k2kpG79xXKKgauJzCmZkFJ5ihwjVnRodVbVjAx64JeB7VyGbF6hEdwpcPcR7Go8x2YZ
