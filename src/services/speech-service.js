const geminiApiKey = process.env.GEMINI_API_KEY;
const geminiSpeechModel =
  process.env.GEMINI_SPEECH_MODEL || process.env.GEMINI_MODEL || "gemini-2.5-flash";
const geminiApiBaseUrl = "https://generativelanguage.googleapis.com/v1beta";
const sarvamApiKey = process.env.SARVAM_API_KEY;
const sarvamSpeechModel = process.env.SARVAM_SPEECH_MODEL || "saaras:v3";
/** BCP-47 hint when the client omits languageCode, e.g. ml-IN, en-IN, or unknown (auto-detect). */
const sarvamSpeechDefaultLanguageCode = (process.env.SARVAM_SPEECH_DEFAULT_LANGUAGE_CODE || "")
  .trim();
const speechProvider = (process.env.SPEECH_TO_TEXT_PROVIDER || "sarvam").trim().toLowerCase();
const sarvamSpeechApiUrl = "https://api.sarvam.ai/speech-to-text";

function extractGeminiText(content) {
  return (content?.parts || [])
    .map((part) => part.text || "")
    .join("")
    .trim();
}

function validateAudioPayload({ audioBase64, mimeType }) {
  if (typeof audioBase64 !== "string" || audioBase64.trim().length === 0) {
    const error = new Error("audioBase64 is required.");
    error.statusCode = 400;
    throw error;
  }

  if (typeof mimeType !== "string" || !mimeType.startsWith("audio/")) {
    const error = new Error("mimeType must be an audio MIME type.");
    error.statusCode = 400;
    throw error;
  }
}

function requireSpeechProviderKey(provider) {
  if (provider === "sarvam") {
    if (!sarvamApiKey) {
      throw new Error("SARVAM_API_KEY is required to transcribe speech with Sarvam.");
    }
    return;
  }

  if (provider === "gemini") {
    if (!geminiApiKey) {
      throw new Error("GEMINI_API_KEY is required to transcribe speech with Gemini.");
    }
    return;
  }

  const error = new Error("SPEECH_TO_TEXT_PROVIDER must be either sarvam or gemini.");
  error.statusCode = 400;
  throw error;
}

function audioFilenameForMimeType(mimeType) {
  const normalized = mimeType.toLowerCase().split(";")[0].trim();
  if (normalized === "audio/wav" || normalized === "audio/wave" || normalized === "audio/x-wav") {
    return "audio.wav";
  }
  if (normalized === "audio/mpeg" || normalized === "audio/mp3") return "audio.mp3";
  if (normalized === "audio/aac") return "audio.aac";
  if (normalized === "audio/flac") return "audio.flac";
  if (normalized === "audio/ogg") return "audio.ogg";
  return "audio";
}

async function readErrorText(response) {
  const text = await response.text();
  if (!text) return "";

  try {
    const data = JSON.parse(text);
    return data?.error?.message || data?.message || text;
  } catch {
    return text;
  }
}

async function transcribeWithSarvam({ audioBase64, mimeType, languageCode }) {
  const audioBuffer = Buffer.from(audioBase64, "base64");
  const formData = new FormData();
  formData.set("model", sarvamSpeechModel);
  formData.set("mode", "transcribe");
  const resolvedLanguage =
    typeof languageCode === "string" && languageCode.trim().length > 0
      ? languageCode.trim()
      : sarvamSpeechDefaultLanguageCode;
  if (resolvedLanguage.length > 0) {
    formData.set("language_code", resolvedLanguage);
  }
  formData.set(
    "file",
    new Blob([audioBuffer], { type: mimeType }),
    audioFilenameForMimeType(mimeType)
  );

  const response = await fetch(sarvamSpeechApiUrl, {
    method: "POST",
    headers: {
      "api-subscription-key": sarvamApiKey
    },
    body: formData
  });

  if (!response.ok) {
    const errorText = await readErrorText(response);
    throw new Error(`Sarvam speech transcription error ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const transcript = typeof data.transcript === "string" ? data.transcript.trim() : "";

  if (!transcript) {
    throw new Error("Sarvam returned no transcription.");
  }

  return {
    transcript,
    provider: "sarvam",
    model: sarvamSpeechModel,
    languageCode: data.language_code ?? null,
    requestId: data.request_id ?? null
  };
}

async function transcribeWithGemini({ audioBase64, mimeType, languageCode }) {
  const languageHint =
    typeof languageCode === "string" && languageCode.trim().length > 0
      ? ` The spoken language hint is ${languageCode.trim()}.`
      : "";

  const response = await fetch(
    `${geminiApiBaseUrl}/models/${geminiSpeechModel}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": geminiApiKey
      },
      body: JSON.stringify({
        contents: [
          {
            role: "user",
            parts: [
              {
                text:
                  "Transcribe this audio exactly into plain text. Return only the transcription, no markdown, no labels." +
                  languageHint
              },
              {
                inlineData: {
                  mimeType,
                  data: audioBase64
                }
              }
            ]
          }
        ]
      })
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini speech transcription error ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const transcript = extractGeminiText(data.candidates?.[0]?.content);

  if (!transcript) {
    throw new Error("Gemini returned no transcription.");
  }

  return {
    transcript,
    provider: "gemini",
    model: data.modelVersion ?? geminiSpeechModel
  };
}

export async function transcribeSpeech({ audioBase64, mimeType, languageCode } = {}) {
  validateAudioPayload({ audioBase64, mimeType });
  requireSpeechProviderKey(speechProvider);

  if (speechProvider === "sarvam") {
    return transcribeWithSarvam({ audioBase64, mimeType, languageCode });
  }

  return transcribeWithGemini({ audioBase64, mimeType, languageCode });
}
