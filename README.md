# SecretVoice MCP Server

A [Model Context Protocol](https://modelcontextprotocol.io) server for **SecretVoice** —
expressive text-to-speech with 29 voices and 22 languages.

- **Endpoint:** `https://api.secretvoice.dev/mcp`
- **Transport:** Streamable HTTP, protocol `2025-06-18`
- **Auth:** OAuth 2.1 with dynamic client registration and PKCE (no API key pasting)
- **Website:** <https://secretvoice.dev/mcp>
- **OAuth reference:** <https://secretvoice.dev/oauth>

## Why this exists

Most TTS integrations make you paste a key into a config file. This one lets the client
register itself, shows you a consent screen, and issues a scoped token that expires in an
hour. Revoke it from your account at any time.

## Tools

| Tool | Description | Scope |
|---|---|---|
| `list_voices` | Every voice with its id and gender | `voices:read` |
| `list_languages` | The 22 supported language codes | `voices:read` |
| `text_to_speech` | Text in, base64 audio out (mp3, opus, wav, pcm) | `tts:generate` |
| `get_balance` | Plan and remaining credits | `account:read` |
| `list_history` | Recent generations | `history:read` |

Resources: `secretvoice://voices`, `secretvoice://languages`.

## Install

### Claude Desktop / Claude Code

`claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "secretvoice": {
      "type": "http",
      "url": "https://api.secretvoice.dev/mcp"
    }
  }
}
```

Restart, then approve the consent screen when it opens.

### Cursor

`~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "secretvoice": { "url": "https://api.secretvoice.dev/mcp" }
  }
}
```

### VS Code / Copilot

```json
{
  "servers": {
    "secretvoice": { "type": "http", "url": "https://api.secretvoice.dev/mcp" }
  }
}
```

### Any client without dynamic registration

Mint an API key at <https://secretvoice.dev/dashboard> and send it directly — the endpoint
accepts both credential types:

```bash
curl -X POST https://api.secretvoice.dev/mcp \
  -H "authorization: Bearer $SECRETVOICE_API_KEY" \
  -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## Example

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "text_to_speech",
    "arguments": {
      "text": "Merhaba, MCP üzerinden Türkçe konuşuyorum.",
      "voice_id": "jade",
      "language_code": "tr"
    }
  }
}
```

The response carries an `audio` content block (base64) plus a JSON block with
`request_id`, `seconds` and `characters`.

## OAuth flow

1. `POST https://secretvoice.dev/oauth/register` with your `redirect_uris` → `client_id`
2. Send the user to `/oauth/authorize` with `code_challenge` (S256), `state` and
   `resource=https://api.secretvoice.dev`
3. `POST /oauth/token` with the code and `code_verifier`
4. Call `/mcp` with `Authorization: Bearer <token>`

Discovery documents:

- <https://secretvoice.dev/.well-known/oauth-authorization-server>
- <https://api.secretvoice.dev/.well-known/oauth-protected-resource>

## Pricing

One credit is one character, the same as the API. A 500-character paragraph costs 500
credits. Plans start at $18/month for 180,000 credits with a free 3-day trial.

## Security

- PKCE S256 required; `plain` is rejected
- Tokens are audience-bound (RFC 8707) and stored hashed
- Access tokens live 1 hour, refresh tokens 30 days and rotate on use
- Revoke with `POST /oauth/revoke` or from the dashboard

## License

MIT — see [LICENSE](LICENSE).

SecretVoice is an independent product; this is not an official Anthropic server.
