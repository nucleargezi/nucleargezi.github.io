export interface OjSummary {
  updated_at: string;
  total: number;
  platforms: Record<string, number>;
}

export interface OjPlatformStat {
  name: string;
  count: number;
}

export interface OjStatsResult {
  available: boolean;
  total?: number;
  updatedAt?: string;
  stats: OjPlatformStat[];
}

const SUMMARY_URL =
  "https://raw.githubusercontent.com/nucleargezi/acm-icpc/master/Z_pack/summary.json";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function parseOjSummary(value: unknown): OjSummary | null {
  if (!isRecord(value)) {
    return null;
  }

  const { updated_at, total, platforms } = value;
  if (typeof updated_at !== "string" || typeof total !== "number" || !isRecord(platforms)) {
    return null;
  }

  const normalizedPlatforms: Record<string, number> = {};

  for (const [name, count] of Object.entries(platforms)) {
    if (typeof count !== "number") {
      return null;
    }

    normalizedPlatforms[name] = count;
  }

  return {
    updated_at,
    total,
    platforms: normalizedPlatforms,
  };
}

function sortPlatformStats(platforms: Record<string, number>): OjPlatformStat[] {
  return Object.entries(platforms)
    .map(([name, count]) => ({ name, count }))
    .sort((left, right) => {
      if (right.count !== left.count) {
        return right.count - left.count;
      }

      return left.name.localeCompare(right.name);
    });
}

export async function getOjStats(): Promise<OjStatsResult> {
  const summaryUrl = import.meta.env.OJ_STATS_URL?.trim() || SUMMARY_URL;

  try {
    const response = await fetch(summaryUrl, {
      headers: {
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`Unexpected response: ${response.status}`);
    }

    const summary = parseOjSummary(await response.json());
    if (!summary) {
      throw new Error("Unexpected summary schema");
    }

    return {
      available: true,
      total: summary.total,
      updatedAt: summary.updated_at,
      stats: sortPlatformStats(summary.platforms),
    };
  } catch (error) {
    console.warn(`[oj-stats] Failed to load summary.json from ${summaryUrl}`, error);

    return {
      available: false,
      stats: [],
    };
  }
}
