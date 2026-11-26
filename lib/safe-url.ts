const IMAGE_HOST_MAP: Record<string, string> = {
  "https://community.akamai.steamstatic.com": "https://community.akamai.steamstatic.com",
  "https://community.cloudflare.steamstatic.com": "https://community.cloudflare.steamstatic.com",
  "https://raw.githubusercontent.com": "https://raw.githubusercontent.com",
};

const SAFE_SEGMENT = /^[A-Za-z0-9_.-]+$/;

function encodeSafePath(pathname: string): string {
  const segments = pathname.split("/").filter(Boolean);
  if (segments.length === 0) return "";
  const encoded: string[] = [];
  for (const seg of segments) {
    if (seg === "." || seg === ".." || !SAFE_SEGMENT.test(seg)) {
      return "";
    }
    encoded.push(encodeURIComponent(seg));
  }
  return "/" + encoded.join("/");
}

/**
 * Reconstructs image URLs only from allowlisted CDN hosts and strictly
 * validated path segments encoded with encodeURIComponent.
 */
export function sanitizeImageUrl(raw: unknown): string {
  if (typeof raw !== "string") return "";
  const trimmed = raw.trim();
  if (!trimmed) return "";

  if (trimmed.startsWith("/") && !trimmed.startsWith("//")) {
    return encodeSafePath(trimmed);
  }

  try {
    const parsed = new URL(trimmed);
    const cdnHost = IMAGE_HOST_MAP[parsed.origin];
    if (!cdnHost) return "";
    const safePath = encodeSafePath(parsed.pathname);
    if (!safePath) return "";
    return `${cdnHost}${safePath}`;
  } catch {
    return "";
  }
}
