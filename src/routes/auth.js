import express from "express";
import { requireAuth } from "../middleware/auth-middleware.js";
import {
  createAuthResponse,
  getUserByEmail,
  loginUser,
  registerUser
} from "../services/auth-service.js";

const router = express.Router();

function validateAuthPayload(payload, { requireName = false } = {}) {
  const errors = [];
  const name = payload.name?.trim() ?? "";
  const email = payload.email?.trim().toLowerCase() ?? "";
  const password = payload.password ?? "";

  if (requireName && name.length < 2) {
    errors.push("name must be at least 2 characters");
  }

  if (!email || !email.includes("@")) {
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
    res.status(201).json(createAuthResponse(user));
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

    const user = await loginUser(value);
    if (!user) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    res.json(createAuthResponse(user));
  } catch (error) {
    next(error);
  }
});

router.get("/auth/me", requireAuth, (req, res) => {
  res.json({ user: req.user });
});

export default router;
