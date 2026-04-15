import path from "node:path";
import { fileURLToPath } from "node:url";
import { logger } from "../logger.js";
import ejs from "ejs";
import nodemailer from "nodemailer";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const smtpHost = process.env.SMTP_HOST;
const smtpPort = Number(process.env.SMTP_PORT || 587);
const smtpUser = process.env.SMTP_USER;
const smtpPass = process.env.SMTP_PASS;
const mailFrom = process.env.MAIL_FROM || smtpUser || "no-reply@example.com";
const appBaseUrl = process.env.APP_BASE_URL || `http://localhost:${process.env.PORT || 3000}`;

let transporter;

function getTransporter() {
  if (transporter) {
    return transporter;
  }

  if (!smtpHost || !smtpUser || !smtpPass) {
    throw new Error("SMTP_HOST, SMTP_USER, and SMTP_PASS are required for email delivery");
  }

  transporter = nodemailer.createTransport({
    host: smtpHost,
    port: smtpPort,
    secure: smtpPort === 465,
    auth: {
      user: smtpUser,
      pass: smtpPass
    }
  });

  return transporter;
}

async function renderTemplate(relativePath, data) {
  const templatePath = path.join(__dirname, "..", "views", relativePath);
  return ejs.renderFile(templatePath, data);
}

async function sendEmail({ to, subject, template, data, text }) {
  const html = await renderTemplate(template, {
    ...data,
    appBaseUrl
  });

  await getTransporter().sendMail({
    from: mailFrom,
    to,
    subject,
    html,
    text
  });
}

export async function sendVerificationEmail({ to, name, token }) {
  try{
  const verificationUrl = `${appBaseUrl}/api/auth/verify-email?token=${encodeURIComponent(token)}`;

  await sendEmail({
    to,
    subject: "Verify your email",
    template: path.join("emails", "verify-email.ejs"),
    data: {
      name,
      verificationUrl
    },
    text: `Verify your email by opening this link: ${verificationUrl}`
  });
  return true;
  } catch (error) {
    logger.error(`Error sending verification email: ${error?.message || error}`, {
      stack: error?.stack
    });
    return false;
  }
}

export async function sendPasswordResetEmail({ to, name, token }) {
  const resetUrl = `${appBaseUrl}/api/auth/reset-password?token=${encodeURIComponent(token)}`;

  await sendEmail({
    to,
    subject: "Reset your password",
    template: path.join("emails", "reset-password-email.ejs"),
    data: {
      name,
      resetUrl
    },
    text: `Reset your password by opening this link: ${resetUrl}`
  });
}

export async function sendEmailChangeVerification({ to, name, token }) {
  const verificationUrl = `${appBaseUrl}/api/auth/verify-email?token=${encodeURIComponent(token)}`;

  await sendEmail({
    to,
    subject: "Confirm your new email address",
    template: path.join("emails", "change-email.ejs"),
    data: {
      name,
      verificationUrl
    },
    text: `Confirm your new email address by opening this link: ${verificationUrl}`
  });
}

export async function sendAccountDeletionEmail({ to, name, token }) {
  const deletionUrl = `${appBaseUrl}/api/auth/delete-account?token=${encodeURIComponent(token)}`;

  await sendEmail({
    to,
    subject: "Confirm account deletion",
    template: path.join("emails", "delete-account.ejs"),
    data: {
      name,
      deletionUrl
    },
    text: `Delete your account and app data by opening this link: ${deletionUrl}`
  });
}

export async function renderPasswordResetPage(data) {
  return renderTemplate(path.join("pages", "reset-password.ejs"), data);
}

export async function renderStatusPage(data) {
  return renderTemplate(path.join("pages", "status-page.ejs"), data);
}

export async function renderDeleteAccountInfoPage(data) {
  return renderTemplate(path.join("pages", "delete-account-info.ejs"), data);
}
