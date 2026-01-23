
import { collection, getCountFromServer, query, where, getDocs, limit, orderBy, getAggregateFromServer, sum, Timestamp } from "firebase/firestore";
import { db } from "~/services/firebase";

export interface DashboardStats {
    memberCount: number;
    groupCount: number;
    chaptersRead: number;
    completionRate: number;
}

export interface GroupChartData {
    name: string;
    rate: number;
}

export interface WeeklyReadingData {
    name: string;
    total: number;
    date: string; // for debugging or tooltip
}

export async function fetchDashboardStats(): Promise<DashboardStats> {
    try {
        // Member Count
        const usersColl = collection(db, "users");
        const memberSnapshot = await getCountFromServer(usersColl);
        const memberCount = memberSnapshot.data().count;

        // Group Count
        const groupsColl = collection(db, "groups");
        const groupSnapshot = await getCountFromServer(groupSnapshotColl(groupsColl));
        const groupCount = groupSnapshot.data().count;

        // Chapters Read (Total Cleared Count across all goals)
        const goalsColl = collection(db, "group_goals");
        const goalsSnapshot = await getAggregateFromServer(goalsColl, {
            totalChaptersRead: sum('total_cleared_count')
        });
        const chaptersRead = goalsSnapshot.data().totalChaptersRead;

        // Completion Rate (Hardcoded for now as it requires complex calculation of total possible chapters)
        const completionRate = 0;

        return {
            memberCount,
            groupCount,
            chaptersRead,
            completionRate,
        };
    } catch (error) {
        console.error("Error fetching dashboard stats:", error);
        return {
            memberCount: 0,
            groupCount: 0,
            chaptersRead: 0,
            completionRate: 0,
        };
    }
}

export async function fetchWeeklyReadingStats(): Promise<WeeklyReadingData[]> {
    try {
        const today = new Date();
        const dayOfWeek = today.getDay(); // 0 (Sun) - 6 (Sat)
        // Calculate Monday of this week (if today is Sun(0), Monday was 6 days ago. If Mon(1), 0 days ago)
        // Adjust so Monday is start: (dayOfWeek + 6) % 7 gives distance from Monday? 
        // Sunday (0): need -6 days. Mon (1): 0. Tue (2): -1. ... Sat (6): -5.
        // Formula: diff = today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1); 
        // Simpler: Mon is 1. 
        const distanceToMon = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
        const monday = new Date(today);
        monday.setDate(today.getDate() - distanceToMon);
        monday.setHours(0, 0, 0, 0);

        // Generate array of 7 dates (Mon-Sun) keys: "YYYY-MM-DD"
        const weekDates: string[] = [];
        const resultTemplate: WeeklyReadingData[] = [];
        // Labels for chart (Will be localized in component, but setting keys here)
        // We'll return generic keys or localized logic should handle it. 
        // Plan said "Mon"-"Sun", we will map 0-6 index to labels in component or here.
        // Let's stick to simple "Mon", "Tue"... here mapping to the dates, component can override labels.
        const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

        for (let i = 0; i < 7; i++) {
            const d = new Date(monday);
            d.setDate(monday.getDate() + i);
            const year = d.getFullYear();
            const month = String(d.getMonth() + 1).padStart(2, '0');
            const day = String(d.getDate()).padStart(2, '0');
            const dateStr = `${year}-${month}-${day}`;
            weekDates.push(dateStr);
            resultTemplate.push({ name: dayLabels[i], total: 0, date: dateStr });
        }

        // Fetch all group goals that have daily_stats
        // Optimization: In a large app, we'd query a separate 'stats' collection or filter by updated_at.
        // For now, fetch all group_goals.
        const goalsColl = collection(db, "group_goals");
        const snapshot = await getDocs(goalsColl);

        snapshot.docs.forEach(doc => {
            const data = doc.data();
            const dailyStats = data.daily_stats as Record<string, number> | undefined;
            if (dailyStats) {
                weekDates.forEach((dateStr, index) => {
                    const count = dailyStats[dateStr];
                    if (count) {
                        resultTemplate[index].total += count;
                    }
                });
            }
        });

        return resultTemplate;

    } catch (error) {
        console.error("Error fetching weekly reading stats:", error);
        return [];
    }
}

// Helper to handle potential query constraints
function groupSnapshotColl(coll: any) {
    return coll;
}

export async function fetchGroupChartData(): Promise<GroupChartData[]> {
    try {
        const groupsColl = collection(db, "groups");
        // Get top 5 groups by member count for the chart
        const q = query(groupsColl, orderBy("memberCount", "desc"), limit(5));
        const snapshot = await getDocs(q);

        return snapshot.docs.map(doc => ({
            name: doc.data().name || "Unknown",
            rate: doc.data().memberCount || 0
        }));
    } catch (error) {
        console.error("Error fetching group chart data:", error);
        return [];
    }
}
