
import { collection, getCountFromServer, query, where } from "firebase/firestore";
import { db } from "~/services/firebase";

export interface DashboardStats {
    memberCount: number;
    groupCount: number;
    chaptersRead: number;
    completionRate: number;
}

export async function fetchDashboardStats(): Promise<DashboardStats> {
    try {
        // Member Count
        const usersColl = collection(db, "users");
        const snapshot = await getCountFromServer(usersColl);
        const memberCount = snapshot.data().count;

        // Group Count
        const groupsColl = collection(db, "groups");
        const groupSnapshot = await getCountFromServer(groupsColl);
        const groupCount = groupSnapshot.data().count;

        // Hardcoded for now until we have reading logs collection structure
        // In future: query reading_logs collection with aggregation
        const chaptersRead = 0;
        const completionRate = 0;

        return {
            memberCount,
            groupCount,
            chaptersRead,
            completionRate,
        };
    } catch (error) {
        console.error("Error fetching dashboard stats:", error);
        // Fallback to Zeros or handle error
        return {
            memberCount: 0,
            groupCount: 0,
            chaptersRead: 0,
            completionRate: 0,
        };
    }
}
