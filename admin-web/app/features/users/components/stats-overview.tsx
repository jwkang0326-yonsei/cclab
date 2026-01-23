
import { Users, BookOpen, Crown } from "lucide-react";

interface StatsOverviewProps {
    memberCount: number;
    groupCount: number;
    chaptersRead: number;
    completionRate: number;
}

export function StatsOverview({ memberCount, groupCount, chaptersRead, completionRate }: StatsOverviewProps) {
    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-xl border bg-card text-card-foreground shadow p-6">
                <div className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <div className="text-sm font-medium">Total Members</div>
                    <Users className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-2xl font-bold">{memberCount}</div>
                <p className="text-xs text-muted-foreground">+20.1% from last month</p>
            </div>
            <div className="rounded-xl border bg-card text-card-foreground shadow p-6">
                <div className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <div className="text-sm font-medium">Active Groups</div>
                    <Crown className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-2xl font-bold">{groupCount}</div>
                <p className="text-xs text-muted-foreground">+3 new groups</p>
            </div>
            <div className="rounded-xl border bg-card text-card-foreground shadow p-6">
                <div className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <div className="text-sm font-medium">Chapters Read</div>
                    <BookOpen className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-2xl font-bold">{chaptersRead.toLocaleString()}</div>
                <p className="text-xs text-muted-foreground">+12% from last week</p>
            </div>
            <div className="rounded-xl border bg-card text-card-foreground shadow p-6">
                <div className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <div className="text-sm font-medium">Completion Rate</div>
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        className="h-4 w-4 text-muted-foreground"
                    >
                        <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
                    </svg>
                </div>
                <div className="text-2xl font-bold">{completionRate}%</div>
                <p className="text-xs text-muted-foreground">+2.4% from last week</p>
            </div>
        </div>
    );
}
