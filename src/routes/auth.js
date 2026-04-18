import express from "express";
import { logger } from "../logger.js";
import { requireAuth } from "../middleware/auth-middleware.js";
import {
  authenticateUserCredentials,
  createAuthResponse,
  deleteAccountWithToken,
  getUserByEmail,
  getValidPasswordResetRecord,
  loginOrRegisterWithGoogle,
  loginUser,
  requestAccountDeletionForUser,
  registerUser,
  requestEmailChange,
  requestPasswordResetForEmail,
  resendVerificationForEmail,
  resetPasswordWithToken,
  updateProfileName,
  verifyEmailToken
} from "../services/auth-service.js";
import {
  renderDeleteAccountInfoPage,
  renderPasswordResetPage,
  renderStatusPage,
  sendAccountDeletionEmail,
  sendEmailChangeVerification,
  sendPasswordResetEmail,
  sendVerificationEmail
} from "../services/mail-service.js";

const router = express.Router();

function isValidEmail(email) {
  return typeof email === "string" && email.includes("@");
}

function validateAuthPayload(payload, { requireName = false } = {}) {
  const errors = [];
  const name = payload.name?.trim() ?? "";
  const email = payload.email?.trim().toLowerCase() ?? "";
  const password = payload.password ?? "";

  if (requireName && name.length < 2) {
    errors.push("name must be at least 2 characters");
  }

  if (!isValidEmail(email)) {
    errors.push("valid email is required");
  }

  if (typeof password !== "string" || password.length < 6) {
    errors.push("password must be at least 6 characters");
  }

  return {
    errors,
    value: { name, email, password }
  };
}

router.post("/auth/register", async (req, res, next) => {
  try {
    const { errors, value } = validateAuthPayload(req.body, { requireName: true });
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const existingUser = await getUserByEmail(value.email);
    if (existingUser) {
      return res.status(409).json({ error: "Email is already registered" });
    }

    const user = await registerUser(value);
    const token = await resendVerificationForEmail(user.email);
    if (token.user && token.token) {
     const isSent = await sendVerificationEmail({
        to: user.email,
        name: user.name,
        token: token.token
      });
      logger.info(`Verification email send result: ${isSent}`);
      if (!isSent) {
        return res.status(500).json({ error: "Failed to send verification email" });
      }
    }

    res.status(201).json({
      message: "Registration successful. Please verify your email before logging in."
    });
  } catch (error) {
    next(error);
  }
});

router.post("/auth/login", async (req, res, next) => {
  try {
    const { errors, value } = validateAuthPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const result = await loginUser(value);
    if (!result.ok) {
      if (result.reason === "EMAIL_NOT_VERIFIED") {
        return res.status(403).json({
          error: "Please verify your email before logging in.",
          code: "EMAIL_NOT_VERIFIED"
        });
      }

      return res.status(401).json({ error: "Invalid email or password" });
    }

    res.json(createAuthResponse(result.user));
  } catch (error) {
    next(error);
  }
});

router.post("/auth/google", async (req, res, next) => {
  try {
    const idToken = req.body?.idToken;
    if (typeof idToken !== "string" || !idToken.trim()) {
      return res.status(400).json({ error: "idToken is required" });
    }

    const result = await loginOrRegisterWithGoogle({ idToken: idToken.trim() });
    if (!result.ok) {
      if (result.reason === "GOOGLE_ACCOUNT_CONFLICT") {
        return res.status(409).json({
          error: "This email is linked to a different Google account."
        });
      }

      return res.status(400).json({ error: "Google sign-in failed" });
    }

    res.json(createAuthResponse(result.user));
  } catch (error) {
    const statusCode = error.statusCode;
    if (statusCode === 401 || statusCode === 403 || statusCode === 503) {
      return res.status(statusCode).json({ error: error.message });
    }

    next(error);
  }
});

router.post("/auth/resend-verification", async (req, res, next) => {
  try {
    const email = req.body.email?.trim().toLowerCase();
    if (!isValidEmail(email)) {
      return res.status(400).json({ error: "valid email is required" });
    }

    const result = await resendVerificationForEmail(email);
    if (result.user && result.token) {
      await sendVerificationEmail({
        to: result.user.email,
        name: result.user.name,
        token: result.token
      });
    }

    res.json({
      message: "If your account exists and is not yet verified, a verification email has been sent."
    });
  } catch (error) {
    next(error);
  }
});

router.get("/auth/verify-email", async (req, res, next) => {
  try {
    const token = String(req.query.token || "");
    const result = await verifyEmailToken(token);

    const html = await renderStatusPage(
      result.ok
        ? {
            success: true,
            title: "Email verified",
            message: "Your email has been verified. You can now sign in from the app."
          }
        : {
            success: false,
            title: "Verification failed",
            message: "This verification link is invalid or has expired."
          }
    );

    res.status(result.ok ? 200 : 400).type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.post("/auth/forgot-password", async (req, res, next) => {
  try {
    const email = req.body.email?.trim().toLowerCase();
    if (!isValidEmail(email)) {
      return res.status(400).json({ error: "valid email is required" });
    }

    const result = await requestPasswordResetForEmail(email);
    if (result.user && result.token) {
      await sendPasswordResetEmail({
        to: result.user.email,
        name: result.user.name,
        token: result.token
      });
    }

    res.json({
      message: "If the email belongs to a verified account, a password reset email has been sent."
    });
  } catch (error) {
    next(error);
  }
});

router.get("/auth/delete-account-info", async (req, res, next) => {
  try {
    const html = await renderDeleteAccountInfoPage({
      appName: "Gulfon",
      developerName: "Gulfon",
      requestUrl: "/api/auth/request-account-deletion",
      success: null,
      message: null,
      email: ""
    });

    res.type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.post("/auth/request-account-deletion", async (req, res, next) => {
  try {
    const email = req.body.email?.trim().toLowerCase() ?? "";
    const password = String(req.body.password ?? "");

    if (!isValidEmail(email) || password.length < 6) {
      const html = await renderDeleteAccountInfoPage({
        appName: "Gulfon",
        developerName: "Gulfon",
        requestUrl: "/api/auth/request-account-deletion",
        success: false,
        message: "Enter a valid email address and password.",
        email
      });

      return res.status(400).type("html").send(html);
    }

    const authResult = await authenticateUserCredentials({ email, password });
    if (!authResult.ok) {
      const html = await renderDeleteAccountInfoPage({
        appName: "Gulfon",
        developerName: "Gulfon",
        requestUrl: "/api/auth/request-account-deletion",
        success: false,
        message: "Invalid email or password.",
        email
      });

      return res.status(401).type("html").send(html);
    }

    const result = await requestAccountDeletionForUser(authResult.user);
    if (result.user && result.token) {
      await sendAccountDeletionEmail({
        to: result.user.email,
        name: result.user.name,
        token: result.token
      });
    }

    const html = await renderDeleteAccountInfoPage({
      appName: "Gulfon",
      developerName: "Gulfon",
      requestUrl: "/api/auth/request-account-deletion",
      success: true,
      message: result.deletedDirectly
        ? "Your unverified account and associated application data were deleted immediately."
        : "Your account is verified. We sent a confirmation email with a secure deletion link.",
      email
    });

    res.type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.get("/auth/delete-account", async (req, res, next) => {
  try {
    const token = String(req.query.token || "");
    const result = await deleteAccountWithToken(token);

    const html = await renderStatusPage(
      result.ok
        ? {
            success: true,
            title: "Account deleted",
            message:
              "Your account and associated application data have been deleted."
          }
        : {
            success: false,
            title: "Deletion failed",
            message:
              "This account deletion link is invalid, expired, or the account was already removed."
          }
    );

    res.status(result.ok ? 200 : 400).type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.get("/auth/reset-password", async (req, res, next) => {
  try {
    const token = String(req.query.token || "");
    const record = await getValidPasswordResetRecord(token);
    const html = await renderPasswordResetPage({
      token,
      email: record?.email ?? "",
      isExpired: !record,
      message: null,
      success: false
    });

    res.status(record ? 200 : 400).type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.post("/auth/reset-password", async (req, res, next) => {
  try {
    const token = String(req.body.token || req.query.token || "");
    const password = String(req.body.password || "");

    if (password.length < 6) {
      const record = await getValidPasswordResetRecord(token);
      const html = await renderPasswordResetPage({
        token,
        email: record?.email ?? "",
        isExpired: !record,
        message: "Password must be at least 6 characters.",
        success: false
      });

      return res.status(400).type("html").send(html);
    }

    const result = await resetPasswordWithToken(token, password);
    const html = await renderStatusPage(
      result.ok
        ? {
            success: true,
            title: "Password updated",
            message: "Your password has been changed. You can now sign in from the app."
          }
        : {
            success: false,
            title: "Reset failed",
            message: "This reset link is invalid or has expired."
          }
    );

    res.status(result.ok ? 200 : 400).type("html").send(html);
  } catch (error) {
    next(error);
  }
});

router.get("/auth/me", requireAuth, (req, res) => {
  res.json({ user: req.user });
});

router.patch("/auth/profile", requireAuth, async (req, res, next) => {
  try {
    const name = req.body.name?.trim() ?? "";
    if (name.length < 2) {
      return res.status(400).json({ error: "name must be at least 2 characters" });
    }

    const user = await updateProfileName(req.user.id, name);
    res.json({ user });
  } catch (error) {
    next(error);
  }
});

router.post("/auth/change-email", requireAuth, async (req, res, next) => {
  try {
    const email = req.body.email?.trim().toLowerCase();
    if (!isValidEmail(email)) {
      return res.status(400).json({ error: "valid email is required" });
    }

    const result = await requestEmailChange(req.user.id, email);
    if (!result.ok) {
      const messages = {
        USER_NOT_FOUND: "User not found",
        EMAIL_NOT_VERIFIED: "Verify your current email before changing it",
        EMAIL_UNCHANGED: "Use a different email address",
        EMAIL_ALREADY_IN_USE: "Email is already in use",
        EMAIL_ALREADY_PENDING: "That email is already waiting for verification"
      };

      return res.status(400).json({ error: messages[result.reason] || "Unable to change email" });
    }

    await sendEmailChangeVerification({
      to: result.nextEmail,
      name: result.user.name,
      token: result.token
    });

    res.json({
      message: "We sent a verification email to your new address. Your email will update after verification."
    });
  } catch (error) {
    next(error);
  }
});

export default router;
