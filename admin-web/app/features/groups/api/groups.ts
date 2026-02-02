
import {
    collection,
    getDocs,
    doc,
    getDoc,
    query,
    where,
    addDoc,
    updateDoc,
    serverTimestamp,
    runTransaction
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

export async function createGroup(name: string, leaderId: string): Promise<string> {
    try {
        const result = await runTransaction(db, async (transaction) => {
            // 1. Get leader info
            const userDocRef = doc(db, "users", leaderId);
            const userDoc = await transaction.get(userDocRef);
            
            if (!userDoc.exists()) {
                throw new Error("사용자 정보를 찾을 수 없습니다.");
            }

            const userData = userDoc.data();
            const leaderName = userData?.displayName || userData?.name || "Unknown Leader";

            // 2. Prepare new group reference
            const groupsColl = collection(db, "groups");
            const newGroupRef = doc(groupsColl); // Generate ID first

            // 3. Create the group
            transaction.set(newGroupRef, {
                name,
                leaderId,
                leaderName,
                memberCount: 1,
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp(),
            });

            // 4. Update leader's user document
            transaction.update(userDocRef, {
                groupId: newGroupRef.id,
                role: "leader",
                updatedAt: serverTimestamp(),
            });

            return newGroupRef.id;
        });

        return result;
    } catch (error) {
        console.error("Error creating group:", error);
        throw error;
    }
}

export async function addMemberToGroup(groupId: string, email: string): Promise<void> {
    try {
        // 1. Find user by email
        const usersColl = collection(db, "users");
        const q = query(usersColl, where("email", "==", email));
        const snapshot = await getDocs(q);

        if (snapshot.empty) {
            throw new Error("해당 이메일을 가진 사용자를 찾을 수 없습니다.");
        }

        const userDoc = snapshot.docs[0];
        const userRef = doc(db, "users", userDoc.id);

        // 2. Update user document with groupId
        await updateDoc(userRef, {
            groupId,
            updatedAt: serverTimestamp(),
        });

        // 3. Increment group member count (Optional but recommended)
        const groupRef = doc(db, "groups", groupId);
        const groupDoc = await getDoc(groupRef);
        if (groupDoc.exists()) {
            const currentCount = groupDoc.data().memberCount || 0;
            await updateDoc(groupRef, {
                memberCount: currentCount + 1,
                updatedAt: serverTimestamp(),
            });
        }
    } catch (error) {
        console.error("Error adding member to group:", error);
        throw error;
    }
}

export async function updateMemberRole(memberId: string, role: string): Promise<void> {
    try {
        const userRef = doc(db, "users", memberId);
        await updateDoc(userRef, {
            role,
            updatedAt: serverTimestamp(),
        });
    } catch (error) {
        console.error("Error updating member role:", error);
        throw error;
    }
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
