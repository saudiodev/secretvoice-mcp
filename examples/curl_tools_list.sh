#!/usr/bin/env bash
# List the tools the SecretVoice MCP server exposes.
curl -s -X POST https://api.secretvoice.dev/mcp \
  -H "authorization: Bearer ${SECRETVOICE_API_KEY:?set SECRETVOICE_API_KEY}" \
  -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq .
