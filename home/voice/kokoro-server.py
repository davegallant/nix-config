"""Minimal OpenAI-compatible Kokoro TTS server (/v1/audio/speech) for local voice chat."""

import io
import os
import subprocess
import threading

import numpy as np
import soundfile as sf
import torch
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response, StreamingResponse
from kokoro import KModel, KPipeline
from pydantic import BaseModel

MODEL_DIR = os.environ["KOKORO_MODEL_DIR"]
DEFAULT_VOICE = os.environ.get("KOKORO_DEFAULT_VOICE", "af_sky")
REPO_ID = "hexgrad/Kokoro-82M"
SAMPLE_RATE = 24000

device = "mps" if torch.backends.mps.is_available() else "cpu"
model = (
    KModel(
        repo_id=REPO_ID,
        config=f"{MODEL_DIR}/config.json",
        model=f"{MODEL_DIR}/kokoro-v1_0.pth",
    )
    .to(device)
    .eval()
)
voices = sorted(f.removesuffix(".pt") for f in os.listdir(f"{MODEL_DIR}/voices"))
# The first letter of a voice name is its language: a = American, b = British English.
pipelines = {
    lang: KPipeline(lang_code=lang, repo_id=REPO_ID, model=model)
    for lang in sorted({v[0] for v in voices})
}
lock = threading.Lock()

app = FastAPI()


class SpeechRequest(BaseModel):
    input: str
    model: str = "kokoro"
    voice: str = DEFAULT_VOICE
    response_format: str = "pcm"
    speed: float = 1.0


def chunks(text: str, voice: str, speed: float):
    if voice not in voices:
        voice = DEFAULT_VOICE
    pipeline = pipelines[voice[0]]
    with lock:
        for result in pipeline(text, voice=f"{MODEL_DIR}/voices/{voice}.pt", speed=speed):
            if result.audio is not None:
                yield result.audio.cpu().numpy()


def pcm16(audio: np.ndarray) -> bytes:
    return (np.clip(audio, -1, 1) * 32767).astype("<i2").tobytes()


@app.get("/health")
@app.get("/v1/health")
def health():
    return {"status": "healthy", "device": device}


@app.get("/v1/models")
def models():
    return {"object": "list", "data": [{"id": "kokoro", "object": "model"}, {"id": "tts-1", "object": "model"}]}


@app.get("/v1/audio/voices")
def list_voices():
    return {"voices": voices}


@app.post("/v1/audio/speech")
def speech(req: SpeechRequest):
    fmt = req.response_format.lower()
    if fmt == "pcm":
        stream = (pcm16(a) for a in chunks(req.input, req.voice, req.speed))
        return StreamingResponse(stream, media_type="audio/pcm")

    parts = list(chunks(req.input, req.voice, req.speed))
    audio = np.concatenate(parts) if parts else np.zeros(0, dtype=np.float32)
    if fmt in ("wav", "flac"):
        buf = io.BytesIO()
        sf.write(buf, audio, SAMPLE_RATE, format=fmt.upper(), subtype="PCM_16")
        return Response(buf.getvalue(), media_type=f"audio/{fmt}")

    codecs = {"mp3": ("mp3", "audio/mpeg"), "opus": ("ogg", "audio/ogg"), "aac": ("adts", "audio/aac")}
    if fmt not in codecs:
        raise HTTPException(400, f"unsupported response_format: {fmt}")
    container, media_type = codecs[fmt]
    out = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-f", "s16le", "-ar", str(SAMPLE_RATE), "-ac", "1", "-i", "-", "-f", container, "-"],
        input=pcm16(audio),
        capture_output=True,
        check=True,
    )
    return Response(out.stdout, media_type=media_type)


if __name__ == "__main__":
    # The first synthesis per language compiles GPU kernels and loads spaCy (~10 s); pay that before serving.
    for lang in pipelines:
        for _ in chunks("Warming up.", next(v for v in voices if v[0] == lang), 1.0):
            pass
    uvicorn.run(app, host="127.0.0.1", port=int(os.environ.get("KOKORO_PORT", "8880")), log_level="warning")
