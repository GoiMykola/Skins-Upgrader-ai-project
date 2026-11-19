import { withMockMode } from "./mock-mode";

export type LeaderboardEntry = {
  rank: number;
  userId: string;
  userName: string;
  userAvatar: string;
  tier: string;
  skinsCount: number;
  totalValue: number;
};

const MOCK_LEADERBOARD: LeaderboardEntry[] = [
  { rank: 1, userId: "demo-player", userName: "demo-player", userAvatar: "D", tier: "Еліта", skinsCount: 18, totalValue: 24860 },
  { rank: 2, userId: "kira", userName: "Kira.exe", userAvatar: "K", tier: "Майстер", skinsCount: 14, totalValue: 19420 },
  { rank: 3, userId: "v1per", userName: "v1per", userAvatar: "V", tier: "Майстер", skinsCount: 12, totalValue: 16890 },
  { rank: 4, userId: "nova", userName: "n0va", userAvatar: "N", tier: "Ветеран", skinsCount: 11, totalValue: 12740 },
];

export async function listLeaderboard(): Promise<LeaderboardEntry[]> {
  return withMockMode(MOCK_LEADERBOARD);
}
