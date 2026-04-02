function pad(value) {
  return String(value).padStart(2, "0");
}

export function formatProjectDate(value) {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "";
  }

  return `${pad(date.getUTCDate())}-${pad(date.getUTCMonth() + 1)}-${date.getUTCFullYear()}`;
}

export function parseProjectDateToIso(value) {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  const projectMatch = trimmed.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (projectMatch) {
    const [, day, month, year] = projectMatch;
    const iso = `${year}-${month}-${day}`;
    return isValidIsoDate(iso) ? iso : null;
  }

  if (isValidIsoDate(trimmed)) {
    return trimmed;
  }

  return null;
}

export function parseProjectMonth(value) {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  if (/^\d{4}-\d{2}$/.test(trimmed)) {
    return trimmed;
  }

  const monthYearMatch = trimmed.match(/^(\d{2})-(\d{4})$/);
  if (monthYearMatch) {
    const [, month, year] = monthYearMatch;
    if (Number(month) >= 1 && Number(month) <= 12) {
      return `${year}-${month}`;
    }
  }

  return null;
}

export function formatProjectMonth(value) {
  const month = parseProjectMonth(value);
  if (!month) {
    return "";
  }

  const [year, monthPart] = month.split("-");
  return `${monthPart}-${year}`;
}

function isValidIsoDate(value) {
  const isoMatch = value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!isoMatch) {
    return false;
  }

  const [, year, month, day] = isoMatch;
  const date = new Date(Date.UTC(Number(year), Number(month) - 1, Number(day)));

  return date.getUTCFullYear() === Number(year)
    && date.getUTCMonth() === Number(month) - 1
    && date.getUTCDate() === Number(day);
}
