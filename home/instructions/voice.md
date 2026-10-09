# Voice

When the user says or types "let's talk" (or similar), call
`mcp__plugin_voice_voicemode__converse` as the very first action. Do not load the
voice skill, run ToolSearch, or read anything first: each extra step is a model
turn of startup latency. Load the voice skill only for setup, debugging, or audio
files.
