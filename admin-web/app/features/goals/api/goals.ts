import { collection, getDocs, doc, getDoc } from "firebase/firestore";
import { db } from "~/services/firebase";

export interface Goal {
    id: string;
    title: string;
    description: string;
    startDate: string;
    endDate: string;
    status: string;
    participantCount: number;
    progress: number;
    targetRange: string[];
    groupName: string;
    dailyStats?: Record<string, number>; // 요일별 통계 추가
}

export async function fetchGoals(): Promise<Goal[]> {
    try {
        const goalsColl = collection(db, "group_goals");
        const snapshot = await getDocs(goalsColl);
        
        const groupNameCache: Record<string, string> = {};

        const goals = await Promise.all(snapshot.docs.map(async (goalDoc) => {
            const data = goalDoc.data();
            const goalId = goalDoc.id;
            const groupId = data.group_id;

            // 목장 이름 가져오기
            let groupName = "Unknown Group";
            if (groupId) {
                if (groupNameCache[groupId]) {
                    groupName = groupNameCache[groupId];
                } else {
                    const groupDoc = await getDoc(doc(db, "groups", groupId));
                    if (groupDoc.exists()) {
                        groupName = groupDoc.data().name || "Unnamed Group";
                        groupNameCache[groupId] = groupName;
                    }
                }
            }

            const participantCount = data.active_participant_count || 0;
            const totalCleared = data.total_cleared_count || 0;
            const totalChapters = data.total_chapters || 260;

            const progress = totalChapters > 0 
                ? Math.round((totalCleared / totalChapters) * 100) 
                : 0;

            return {
                id: goalId,
                title: data.title || "Untitled Goal",
                description: data.description || "",
                startDate: data.start_date?.toDate?.()?.toLocaleDateString() || data.start_date || "",
                endDate: data.end_date?.toDate?.()?.toLocaleDateString() || data.end_date || "",
                status: data.status || 'ACTIVE',
                participantCount: participantCount,
                progress: progress,
                targetRange: data.target_range || [],
                groupName: groupName,
                dailyStats: data.daily_stats || {}, // DB 필드 연결
            } as Goal;
        }));

        return goals;
    } catch (error) {
        console.error("Error fetching goals:", error);
        return [];
    }
}
