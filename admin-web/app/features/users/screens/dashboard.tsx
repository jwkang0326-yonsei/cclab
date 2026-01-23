import type { Route } from "./+types/dashboard";
import { useTranslation } from "react-i18next";
import { useEffect, useState } from "react";
import { Button } from "~/core/components/ui/button";
import { signOut } from "~/features/auth/api/auth";
import { StatsOverview } from "~/features/users/components/stats-overview";
import { ReadingProgressChart } from "~/features/users/components/reading-progress-chart";
import { GroupParticipationChart } from "~/features/users/components/group-participation-chart";
import { fetchDashboardStats, type DashboardStats } from "~/features/users/api/dashboard";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Dashboard | Admin Web" }];
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

    useEffect(() => {
        fetchDashboardStats().then(setStats);
    }, []);

    const handleLogout = async () => {
        await signOut();
        window.location.href = "/login";
    };

    // Mock Data for Charts (until we have real historical data)
    const readingData = [
        { name: "Jan", total: 1200 },
        { name: "Feb", total: 2100 },
        { name: "Mar", total: 3400 },
        { name: "Apr", total: 4521 },
        { name: "May", total: 5100 },
        { name: "Jun", total: 6000 },
    ];

    const groupData = [
        { name: "Sarang", rate: 85 },
        { name: "Joy", rate: 65 },
        { name: "Peace", rate: 90 },
        { name: "Hope", rate: 45 },
        { name: "Faith", rate: 70 },
    ];

    return (
        <div className="flex-1 space-y-4 p-8 pt-6">
            <div className="flex items-center justify-between space-y-2">
                <h2 className="text-3xl font-bold tracking-tight">Dashboard</h2>
                <div className="flex items-center space-x-2">
                    <Button variant="outline" onClick={handleLogout}>
                        Sign out
                    </Button>
                </div>
            </div>

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
        </div>
    );
}
