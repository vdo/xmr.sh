# xmr.sh

**xmr.sh** script wizard sets up a new server running a monero node daemon with Docker compose, with your choice of SSL certificates for your domain, network selection, a Tor hidden service, Grafana dashboard and more.

## Distribution support

Compatible and tested on:

- Debian 11
- Ubuntu Focal
- Fedora 36

Other distributions with docker pre-installed would probably be compatible as well.

## ToDo

- [x] Add wizard for DNS domain selection.
- [x] Status and node info at finish.
- [x] Mainnet / Stagenet / Testnet selection
- [ ] Pruning option
- [x] Clearnet TLS port selection
- [ ] Uninstall script
- [ ] Documentation
- [x] Make tor service optional
- [x] (Optional) block explorer
- [x] Grafana dashboard
- [ ] arm64 support for all images.
- [ ] monerod-lws support.
- [ ] monerod-proxy support.
