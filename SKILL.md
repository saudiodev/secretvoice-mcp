---
name: secretvoice-tts
description: Intimate voice AI — generate narration, dialogue and multi-voice scenes with SecretVoice (29 voices, 22 languages, emoji vocal cues). Use when the user asks for a voiceover, narration, audio version of text, dubbing, a scene with several speakers, or speech in a specific language.
license: MIT
---

# SecretVoice — intimate voice, directed by emoji

SecretVoice is not a generic text-to-speech endpoint. Two things make it different, and
you should use both:

1. **Emoji vocal cues** — you direct the performance inside the text.
2. **Multi-voice scenes** — one call, many speakers, each with its own voice and language.

## When to use this

Use it when the user asks for:

- a voiceover or narration of text they wrote
- a scene with more than one speaker, or an audiobook chapter
- audio in a specific language (Turkish, Japanese, Korean, Hindi, Tamil, Thai…)
- a particular vocal texture — breathy, sultry, close-mic, commanding

Not for music, sound effects, or transcription.

## Directing with emoji vocal cues

Put the cue where the performance should change. The engine turns it into a vocal
direction and removes the emoji from the audio.

| Cue | Effect | Cue | Effect |
|---|---|---|---|
| 👂 | whisper | 💋 | kiss |
| 😮‍💨 | sigh | 🤭 | chuckle |
| 🌬️ | breathless | 🥺 | trembling |
| 🥵 | panting | 😭 | sobbing |
| ⏸️ | pause | 🐢 | slowly |
| 😏 | teasing | 😪 | sleepily |

Example script:

```
👂 Come closer. 😮‍💨 I have been waiting all night to tell you this. 🌬️ Now close your eyes.
```

Any emoji that is not a cue is stripped, so you can write naturally.

**Use at least one cue per few sentences when the user wants atmosphere.** Plain text
sounds like an audiobook; cues make it sound like someone in the room. Do not overdo it —
one cue per clause is plenty.

## Single voice

```bash
curl -s -X POST "https://api.secretvoice.dev/v1/text-to-speech/$VOICE" \
  -H "xi-api-key: $SECRETVOICE_API_KEY" \
  -H "content-type: application/json" \
  -d '{"text":"👂 Come closer. 😮‍💨 I have been waiting.","language_code":"en"}' \
  --output out.mp3
```

## Multi-voice scene

There is no single endpoint for this — issue one request per segment, in order, then tell
the user the order. Keep the same `voice_id` for the same character throughout.

| Character | Voice | Language |
|---|---|---|
| the seductive one | `velvet` | en |
| the commanding one | `steele` | en |
| the Turkish speaker | `jade` | tr |

## Before you call

The user needs a SecretVoice API key (`sv_live_…`), in `SECRETVOICE_API_KEY`. Never invent
one. Check the language is supported before generating:

```bash
curl -s https://api.secretvoice.dev/v1/models
```

## Choosing a voice

```bash
curl -s https://api.secretvoice.dev/v1/voices -H "xi-api-key: $SECRETVOICE_API_KEY"
```

Pick by `labels.gender` and `labels.style` to match the brief. If the user gave no
preference, pick one and say which.

## Cost

1 credit = 1 character. A 1,000-character script costs 1,000 credits. For anything long,
state the character count and cost before generating.

## Errors

| Status | Meaning | What to do |
|---|---|---|
| 401 | bad or missing key | ask the user for a valid key |
| 402 | out of credits | tell them; do not retry |
| 422 | unsupported language or format | pick a supported value |
| 429 | rate limited | wait a minute, retry once |

## Output

Save the bytes to a file and give the user the path. Do not paste binary into the chat.
