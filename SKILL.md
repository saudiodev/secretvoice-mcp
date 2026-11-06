---
name: secretvoice-tts
description: Generate speech with SecretVoice — 29 voices, 22 languages, expressive and intimate narration. Use when the user asks for a voiceover, narration, audio version of text, dubbing, or text-to-speech, including non-English languages.
license: MIT
---

# SecretVoice text-to-speech

Turns text into natural speech through the SecretVoice API. 29 premade voices, 22
languages, 1 credit per character.

## When to use this

Use it when the user asks for:

- a voiceover or narration of text they wrote
- an audio version of an article, script, or scene
- speech in a specific language (Turkish, Japanese, Korean, Hindi, Tamil, Thai…)
- a specific voice character (breathy, warm, commanding, playful)

Do **not** use it for music, sound effects, or transcription — it only synthesizes speech.

## Before you call it

The user needs a SecretVoice API key (`sv_live_…`). Ask for it if it is not already in the
environment as `SECRETVOICE_API_KEY`. Never invent one.

## Generate speech

```bash
curl -s -X POST "https://api.secretvoice.dev/v1/text-to-speech/$VOICE" \
  -H "xi-api-key: $SECRETVOICE_API_KEY" \
  -H "content-type: application/json" \
  -d '{"text":"…","language_code":"en"}' \
  --output out.mp3
```

| Parameter | Notes |
|---|---|
| `text` | Required. Max 5,000 characters per request — split longer text into chunks. |
| `language_code` | Defaults to `en`. Must be one of the 22 supported codes. |
| `voice_settings` | Optional: `stability` (0–1), `similarity_boost` (0–1), `speed` (0.5–2). |

## Choosing a voice

List them first; do not guess an id:

```bash
curl -s https://api.secretvoice.dev/v1/voices -H "xi-api-key: $SECRETVOICE_API_KEY"
```

Pick by `labels.gender` and `labels.style` to match the user's brief. If the user gave no
preference, pick one and say which you used.

## Checking the language

```bash
curl -s https://api.secretvoice.dev/v1/models
```

The `languages` array is the authoritative list. If the user's language is missing, say so
instead of generating in the wrong language.

## Cost

1 credit = 1 character. A 1,000-character script costs 1,000 credits. Before generating
something long, tell the user the character count and the credit cost.

## Errors you may see

| Status | Meaning | What to do |
|---|---|---|
| 401 | bad or missing key | ask the user for a valid key |
| 402 | out of credits | tell them; do not retry |
| 422 | unsupported language or format | pick a supported value |
| 429 | rate limited | wait a minute and retry once |

## Output

The endpoint returns audio bytes (mp3 by default). Save to a file and give the user the
path; do not paste binary into the conversation.
