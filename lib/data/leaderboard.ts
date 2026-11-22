export type LeaderboardEntry = {
  rank: number;
  userId: string;
  userName: string;
  userAvatar: string;
  tier: string;
  skinsCount: number;
  totalValue: number;
};

export async function listLeaderboard(): Promise<LeaderboardEntry[]> {
  return [
    { rank: 1, userId: "user-top-1", userName: "s1mple_fan", userAvatar: "https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=120&auto=format&fit=crop&q=80", tier: "Global Elite", skinsCount: 42, totalValue: 84200 },
    { rank: 2, userId: "user-top-2", userName: "b1t_junior", userAvatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120&auto=format&fit=crop&q=80", tier: "Supreme", skinsCount: 31, totalValue: 56100 },
    { rank: 3, userId: "user-top-3", userName: "m0NESY_peek", userAvatar: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=120&auto=format&fit=crop&q=80", tier: "Legendary Eagle", skinsCount: 19, totalValue: 31400 },
  ];
}
