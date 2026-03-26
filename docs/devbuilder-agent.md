# Developer Agent (`devbuilder`) Setup Notes

This document captures the practical flow used to create and validate a dedicated OpenClaw developer agent in this Docker setup.

## Goal

Create a dedicated agent that:
- owns implementation/build work
- uses Codex through ACP/ACPX when available
- uses Context7 for external docs/reference
- stays separate from the main personal assistant workspace

## Agent shape

Recommended agent id:
- `devbuilder`

Recommended workspace:
- `/home/node/.openclaw/workspace-devbuilder`

Recommended agent dir:
- `/home/node/.openclaw/agents/devbuilder/agent`

## Runtime recommendation

For a real Codex-backed developer agent, the agent entry should use ACP runtime:

```json
{
  "id": "devbuilder",
  "name": "devbuilder",
  "workspace": "/home/node/.openclaw/workspace-devbuilder",
  "agentDir": "/home/node/.openclaw/agents/devbuilder/agent",
  "runtime": {
    "type": "acp",
    "acp": {
      "agent": "codex",
      "backend": "acpx",
      "mode": "persistent",
      "cwd": "/home/node/.openclaw/workspace-devbuilder"
    }
  }
}
```

## Important control-path lesson

For newly created agents, `sessions_send` is not the best first validation path if there is no active target session yet.

Reliable validation path:

```bash
openclaw agent --agent devbuilder --message "Reply with exactly: OK"
```

This is a practical first-run validation path for the agent entry itself.

## Codex auth gotcha

ACP/ACPX can be wired correctly while Codex still fails with:

```text
RUNTIME: Authentication required
```

Root cause:
- the Codex runtime depends on real Codex auth state/API credentials
- the ACP server alone is not enough

Practical notes:
- `@openai/codex` is the real Codex CLI package
- the ACP wrapper is not the right place to expect a friendly login link by itself
- this setup should be documented as requiring Codex authentication before long-running dev work is delegated successfully

## Context7 support: what actually works

The free supported path discovered in this environment is:

```bash
ctx7 library react "How to use hooks for state management"
ctx7 docs /reactjs/react.dev "How to use hooks for state management"
```

This works without login/API key for normal docs lookup.

Important distinction:
- **Context7 CLI (`ctx7`)** is the practical free path
- **Context7 MCP** needs extra auth/config wiring and should not be claimed unless it is actually configured

## UI/UX specialist support

If the developer agent should do frontend/UI work, pair it with:
- ClawHub `ui-ux-pro-max-skill` as the prompt/workflow layer
- the cloned upstream engine repo as the real local search/data engine if advanced local Python search is needed

## Recommendation for this repo

This Docker setup should document a clear pattern:
1. main personal assistant stays focused on orchestration and reporting
2. dedicated developer agent owns implementation/build work
3. Codex auth must be completed before ACP-backed development is expected to work reliably
4. free Context7 docs lookup should use `ctx7` CLI unless MCP is explicitly configured
