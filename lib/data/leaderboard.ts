export type LeaderboardEntry = {
  rank: number;
  userId: string;
  userName: string;
  userAvatar: string;
  tier: string;
  skinsCount: number;
  totalValue: number;
};

// ЗАГЛУШКА: реалізація на кроці 13
export async function listLeaderboard(): Promise<LeaderboardEntry[]> {
  return [];
}
