# Local speech services for Claude Code voice chat: Whisper (STT) on 127.0.0.1:2022 and
# Kokoro (TTS) on 127.0.0.1:8880, both OpenAI-compatible and on the Apple GPU.
{
  config,
  hostname ? "",
  lib,
  pkgs,
  ...
}:
let
  logDir = "${config.home.homeDirectory}/Library/Logs";

  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/5359861c739e955e79d9a303bcbc70fb988958b1/ggml-base.bin";
    sha256 = "60ed5bc3dd14eea856493d334349b405782ddcaf0028d4b5df4088345fba2efe";
  };

  kokoroRev = "f3ff3571791e39611d31c381e3a41a3af07b4987";
  kokoroFile =
    path: sha256:
    pkgs.fetchurl {
      url = "https://huggingface.co/hexgrad/Kokoro-82M/resolve/${kokoroRev}/${path}";
      inherit sha256;
    };
  kokoroVoices = {
    af_bella = "8cb64e02fcc8de0327a8e13817e49c76c945ecf0052ceac97d3081480e8e48d6";
    af_heart = "0ab5709b8ffab19bfd849cd11d98f75b60af7733253ad0d67b12382a102cb4ff";
    af_sky = "c799548aed06e0cb0d655a85a01b48e7f10484d71663f9a3045a5b9362e8512c";
    am_adam = "ced7e284aba12472891be1da3ab34db84cc05cc02b5889535796dbf2d8b0cb34";
    am_michael = "9a443b79a4b22489a5b0ab7c651a0bcd1a30bef675c28333f06971abbd47bd37";
    bf_emma = "d0a423deabf4a52b4f49318c51742c54e21bb89bbbe9a12141e7758ddb5da701";
    bm_george = "f1bc812213dc59774769e5c80004b13eeb79bd78130b11b2d7f934542dab811b";
  };
  kokoroModel = pkgs.linkFarm "kokoro-82m" (
    [
      {
        name = "config.json";
        path = kokoroFile "config.json" "5abb01e2403b072bf03d04fde160443e209d7a0dad49a423be15196b9b43c17f";
      }
      {
        name = "kokoro-v1_0.pth";
        path = kokoroFile "kokoro-v1_0.pth" "496dba118d1a58f5f3db2efc88dbdc216e0483fc89fe6e47ee1f2c53f18ad1e4";
      }
    ]
    ++ lib.mapAttrsToList (voice: sha256: {
      name = "voices/${voice}.pt";
      path = kokoroFile "voices/${voice}.pt" sha256;
    }) kokoroVoices
  );

  kokoroPython = pkgs.python3.withPackages (ps: [
    ps.fastapi
    ps.kokoro
    ps.soundfile
    ps.spacy-models.en_core_web_sm
    ps.uvicorn
  ]);
in
lib.mkIf (hostname == "kratos") {
  launchd.agents.whisper = {
    enable = true;
    config = {
      ProgramArguments = [
        "${lib.getBin pkgs.whisper-cpp}/bin/whisper-server"
        "--model"
        "${whisperModel}"
        "--host"
        "127.0.0.1"
        "--port"
        "2022"
        "--inference-path"
        "/v1/audio/transcriptions"
        "--convert"
      ];
      # --convert shells out to ffmpeg for non-WAV uploads.
      EnvironmentVariables.PATH = "${lib.getBin pkgs.ffmpeg}/bin:/usr/bin:/bin";
      KeepAlive = true;
      ProcessType = "Interactive";
      RunAtLoad = true;
      StandardErrorPath = "${logDir}/whisper.log";
      StandardOutPath = "${logDir}/whisper.log";
      WorkingDirectory = "/tmp";
    };
  };

  launchd.agents.kokoro = {
    enable = true;
    config = {
      ProgramArguments = [
        "${kokoroPython}/bin/python"
        "${./voice/kokoro-server.py}"
      ];
      EnvironmentVariables = {
        HF_HUB_OFFLINE = "1";
        HOME = config.home.homeDirectory;
        KOKORO_MODEL_DIR = "${kokoroModel}";
        PATH = "${lib.getBin pkgs.ffmpeg}/bin:/usr/bin:/bin";
        # Ops missing on MPS fall back to the CPU instead of failing.
        PYTORCH_ENABLE_MPS_FALLBACK = "1";
      };
      KeepAlive = true;
      ProcessType = "Interactive";
      RunAtLoad = true;
      StandardErrorPath = "${logDir}/kokoro.log";
      StandardOutPath = "${logDir}/kokoro.log";
    };
  };
}
