import { collection, getDocs, doc, getDoc, query, orderBy } from "firebase/firestore";
import { db } from "~/services/firebase";

export interface User {
    id: string;
    name: string;
    email: string;
    role: string;
    groupId?: string;
    groupName?: string;
    avatarUrl?: string;
    createdAt?: string;
}

export async function fetchAllUsers(): Promise<User[]> {
    try {
        const usersColl = collection(db, "users");
        const snapshot = await getDocs(usersColl);
        
        const groupNameCache: Record<string, string> = {};

        const users = await Promise.all(snapshot.docs.map(async (userDoc) => {
            const data = userDoc.data();
            const groupId = data.groupId || data.group_id;
            let groupName = "No Group";

            if (groupId) {
                if (groupNameCache[groupId]) {
                    groupName = groupNameCache[groupId];
                } else {
                    try {
                        const groupSnapshot = await getDoc(doc(db, "groups", groupId));
                        if (groupSnapshot.exists()) {
                            groupName = groupSnapshot.data().name || "Unnamed Group";
                            groupNameCache[groupId] = groupName;
                        }
                    } catch (e) {
                        console.warn(`Failed to fetch group name for ${groupId}`);
                    }
                }
            }

            return {
                id: userDoc.id,
                name: data.displayName || data.name || "Unknown",
                email: data.email || "",
                role: data.role || "member",
                groupId: groupId,
                groupName: groupName,
                avatarUrl: data.photoURL || data.avatarUrl,
                createdAt: data.createdAt?.toDate?.()?.toLocaleDateString() || "",
            } as User;
        }));

        return users;
    } catch (error) {
        console.error("Error fetching all users:", error);
        return [];
    }
}
