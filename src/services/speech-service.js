const geminiApiKey = process.env.GEMINI_API_KEY;
const geminiSpeechModel =
  process.env.GEMINI_SPEECH_MODEL || process.env.GEMINI_MODEL || "gemini-2.5-flash";
const geminiApiBaseUrl = "https://generativelanguage.googleapis.com/v1beta";

function extractGeminiText(content) {
  return (content?.parts || [])
    .map((part) => part.text || "")
    .join("")
    .trim();
}

function validateAudioPayload({ audioBase64, mimeType }) {
  if (!geminiApiKey) {
    throw new Error("GEMINI_API_KEY is required to transcribe speech.");
  }

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

export async function transcribeSpeech({ audioBase64, mimeType, languageCode } = {}) {
  validateAudioPayload({ audioBase64, mimeType });

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
