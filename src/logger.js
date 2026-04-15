import dotenv from "dotenv";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import winston from "winston";

dotenv.config({ quiet: true });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(__dirname, "..");

const logFile = process.env.LOG_FILE
  ? path.isAbsolute(process.env.LOG_FILE)
    ? process.env.LOG_FILE
    : path.join(repoRoot, process.env.LOG_FILE)
  : path.join(repoRoot, "logs", "app.log");

fs.mkdirSync(path.dirname(logFile), { recursive: true });

const PINK = "\x1b[38;2;255;182;193m";
const RESET = "\x1b[0m";
const DIM = "\x1b[2m";

const logLevel = process.env.LOG_LEVEL || "http";

const consoleFormat = winston.format.printf(({ level, message, timestamp }) => {
  return `${DIM}${timestamp} [${level}]${RESET} ${PINK}${message}${RESET}`;
});

export const logger = winston.createLogger({
  level: logLevel,
  transports: [
    new winston.transports.File({
      filename: logFile,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      )
    }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
        winston.format.errors({ stack: true }),
        consoleFormat
      )
    })
  ]
});

/**
 * Logs every HTTP request after the response is finished (method, URL, status, duration).
 * Mount once after body parsers and before route definitions.
 */
export function requestLogger() {
  return (req, res, next) => {
    const start = Date.now();
    res.on("finish", () => {
      logger.http(`${req.method} ${req.originalUrl} ${res.statusCode} ${Date.now() - start}ms`);
    });
    next();
  };
}
