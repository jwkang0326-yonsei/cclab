import type { Route } from "./+types/dashboard";
import { useTranslation } from "react-i18next";
import { useEffect, useState } from "react";
import { Button } from "~/core/components/ui/button";
import { signOut } from "~/features/auth/api/auth";
import { StatsOverview } from "~/features/users/components/stats-overview";
import { ReadingProgressChart } from "~/features/users/components/reading-progress-chart";
import { GroupParticipationChart } from "~/features/users/components/group-participation-chart";
import { fetchDashboardStats, fetchGroupChartData, fetchWeeklyReadingStats, type DashboardStats, type GroupChartData, type WeeklyReadingData } from "~/features/users/api/dashboard";

export const meta: Route.MetaFunction = () => {
    return [{ title: "대시보드 | Admin Web" }];
};

export async function loader({ request }: Route.LoaderArgs) {
    return {};
}

export default function Dashboard() {
    const { t } = useTranslation();
    const [stats, setStats] = useState<DashboardStats>({
        memberCount: 0,
        groupCount: 0,
        chaptersRead: 0,
        completionRate: 0,
    });
    const [groupData, setGroupData] = useState<GroupChartData[]>([]);
    const [readingData, setReadingData] = useState<WeeklyReadingData[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function loadDashboard() {
            setLoading(true);
            try {
                const [statsData, groups, weeklyReading] = await Promise.all([
                    fetchDashboardStats(),
                    fetchGroupChartData(),
                    fetchWeeklyReadingStats()
                ]);
                setStats(statsData);
                setGroupData(groups);

                // Localize day names for the chart
                const dayMap: Record<string, string> = {
                    "Mon": "월", "Tue": "화", "Wed": "수", "Thu": "목", "Fri": "금", "Sat": "토", "Sun": "일"
                };

                const localizedReadingData = weeklyReading.map(d => ({
                    ...d,
                    name: dayMap[d.name] || d.name
                }));
                setReadingData(localizedReadingData);

            } finally {
                setLoading(false);
            }
        }
        loadDashboard();
    }, []);

    const handleLogout = async () => {
        await signOut();
        window.location.href = "/login";
    };

    return (
        <div className="flex-1 space-y-4 p-8 pt-6">
            <div className="flex items-center justify-between space-y-2">
                <h2 className="text-3xl font-bold tracking-tight">대시보드</h2>
                <div className="flex items-center space-x-2">
                    <Button variant="outline" onClick={handleLogout}>
                        로그아웃
                    </Button>
                </div>
            </div>

            {loading ? (
                <div className="flex h-64 items-center justify-center">대시보드 데이터 불러오는 중...</div>
            ) : (
                <div className="space-y-4">
                    {/* Key Metrics */}
                    <StatsOverview
                        memberCount={stats.memberCount}
                        groupCount={stats.groupCount}
                        chaptersRead={stats.chaptersRead}
                        completionRate={stats.completionRate}
                    />

                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                        {/* Main Chart */}
                        <ReadingProgressChart data={readingData} />

                        {/* Secondary Chart */}
                        <GroupParticipationChart data={groupData} />
                    </div>
                </div>
            )}
        </div>
    );
}
