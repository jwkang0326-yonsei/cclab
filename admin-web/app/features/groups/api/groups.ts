
import {
    collection,
    getDocs,
    doc,
    getDoc,
    query,
    where
} from "firebase/firestore";
import { db } from "~/services/firebase";

export interface Group {
    id: string;
    name: string;
    leaderName: string;
    memberCount: number; // In real app, this might be aggregated or count of sub-collection
}

export interface Member {
    id: string;
    name: string;
    email: string;
    role: string;
    avatarUrl?: string;
}

export async function fetchGroups(): Promise<Group[]> {
    try {
        const groupsColl = collection(db, "groups");
        const snapshot = await getDocs(groupsColl);
        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                ...data, // Spread first to avoid overwriting normalized fields
                id: doc.id,
                name: data.name || data.groupName || data.group_name || "Unnamed Group",
                leaderName: data.leaderName || data.leader_name || "Unknown Leader",
                memberCount: data.memberCount || data.member_count || 0,
            } as Group;
        });
    } catch (error) {
        console.error("Error fetching groups:", error);
        return [];
    }
}

export async function fetchGroupById(groupId: string): Promise<Group | null> {
    try {
        const groupDoc = doc(db, "groups", groupId);
        const snapshot = await getDoc(groupDoc);
        if (snapshot.exists()) {
            const data = snapshot.data();
            console.log("Fetched Group Data:", data); // Keep debugging
            return {
                ...data, // Spread first
                id: snapshot.id,
                name: data.name || data.groupName || data.group_name || "Unnamed Group",
                leaderName: data.leaderName || data.leader_name || "Unknown Leader",
                memberCount: data.memberCount || data.member_count || 0,
            } as Group;
        }
        return null;
    } catch (error) {
        console.error("Error fetching group details:", error);
        return null;
    }
}

export async function fetchGroupMembers(groupId: string): Promise<Member[]> {
    try {
        const usersColl = collection(db, "users");
        const q = query(usersColl, where("groupId", "==", groupId));
        const snapshot = await getDocs(q);
        return snapshot.docs.map(doc => ({
            id: doc.id,
            name: doc.data().displayName || "Unknown",
            email: doc.data().email || "",
            role: doc.data().role || "Member",
            avatarUrl: doc.data().photoURL
        } as Member));
    } catch (error) {
        console.error("Error fetching group members:", error);
        return [];
    }
}
