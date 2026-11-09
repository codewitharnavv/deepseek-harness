# DeepSeek Harness

English | [中文](README.zh.md)

DeepSeek Harness (`dsh`) is an open-source agent harness developed by [DeepSeek AI](https://deepseek.com).

It is built on an **everything-is-a-plugin** architecture and powered by [Cordis](https://github.com/cordiverse/cordis), whose design is described in [_A Programming Paradigm for Spatiotemporal Composability_](https://arxiv.org/abs/2608.25512).

Documentation: [https://deepseek-harness.github.io/deepseek-harness/](https://deepseek-harness.github.io/deepseek-harness/)

## Developer preview

DeepSeek Harness is in _developer preview_ and iterating rapidly. **THERE WILL BE COMPATIBILITY-BREAKING CHANGES.**

Review the [safety notice](SAFETY.md) before running the project.

## Run

### Run from `npm`

Install `Node.js`, then run:

```sh
npx @deepseek-ai/dsh web
```

The command starts the Web UI at `http://127.0.0.1:3080` by default and opens it in the default browser for a local launch. An SSH launch only prints the host URL because the SSH client or editor owns the local forwarded address. Pass `--no-open` to run the server without opening a browser. See [Web UI guide](docs/user/guide/index.md).

### Run from source

To run from a repository checkout:

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

`pnpm run build` prepares the repository artifacts. `pnpm dsh web` uses those built artifacts without rebuilding.

### Local Windows setup in this checkout

The steps below assume the source prerequisites described above are installed and built (pnpm install and pnpm run build).

This checkout also contains four local setup helpers: `local-setup.cordis.yml`, `run-local.ps1`, `Install-Nuclei.ps1`, and `Scan-LocalTestApp.ps1`.

1. Put `ABLITERATION_API_KEY` and `FIRECRAWL_API_KEY` in a `.env` file one directory above this checkout (for example, `REA\.env`). Keep that file private; the launcher reads the values into the process environment and does not put them in the DSH config.
2. In PowerShell, from this repository directory, run `.\Install-Nuclei.ps1` once if Nuclei is not installed. It installs Nuclei under `%LOCALAPPDATA%\Programs\Nuclei` and checks the official release checksum.
3. Start the local DSH setup with `.\run-local.ps1 --no-open`. It applies `local-setup.cordis.yml` and starts the DSH web UI on its default address, `http://127.0.0.1:3080`. If that port is already in use, resolve the existing DSH instance before launching another.
4. Start your own test app at `http://127.0.0.1:5000` before using Playwright or running `.\Scan-LocalTestApp.ps1`. The test app is separate from the DSH web UI. The scan script is intentionally fixed to that one local address, limits request rate/concurrency, disables redirects, and disables OAST/interactsh.

`local-setup.cordis.yml` configures the Abliteration API model, Playwright MCP with `http://127.0.0.1:5000` as its allowed origin, and the Firecrawl hosted MCP. Firecrawl requests leave the computer and require your private API key.

Use these helpers only for your own local test app. Do not put API key values in this repository, paste keys into YAML or command history, expand the Nuclei target to other hosts, or remove the scan script's local-only safeguards. Review [SAFETY.md](SAFETY.md) before running DSH.

## Community and support

- Submit feedback or bug reports through [GitHub Discussions](https://github.com/deepseek-ai/deepseek-harness/discussions).
- Add the [`dsh-plugin`](https://github.com/topics/dsh-plugin) topic to your plugin repository for discoverability.
- Join <a href="https://discord.gg/4MrtZUhpxg">DeepSeek Harness Discord community</a>.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

Start with the [development guide](docs/development.md) and [architecture documentation](docs/architecture.md).

`pnpm run dev:web` builds, serves, and rebuilds client bundles on source edits in one terminal, and `make help` lists the matching Make targets for Web and Desktop; the guide's application commands section owns the full table.

For agents, follow [AGENTS.md](AGENTS.md).

## Citation

```bibtex
@misc{deepseek-harness2026,
  title={DeepSeek Harness: Everything is a Plugin},
  author={DeepSeek-AI},
  year={2026},
  publisher={GitHub},
  howpublished={\url{https://github.com/deepseek-ai/deepseek-harness}},
}
```

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
