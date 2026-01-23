import { signInWithEmailAndPassword, signOut as firebaseSignOut } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "~/services/firebase";

export async function signIn(email: string, password: string) {
    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        // Verify Admin Role
        const userDocRef = doc(db, "users", user.uid);
        const userDoc = await getDoc(userDocRef);

        if (!userDoc.exists()) {
            await firebaseSignOut(auth);
            throw new Error("Access denied: User profile not found.");
        }

        const userData = userDoc.data();
        const role = userData?.role;
        const church_id = userData?.church_id;

        if (role === 'super-admin') {
            // Super Admin: Access granted
        } else if (role === 'admin') {
            // Admin: Must have church_id
            if (!church_id) {
                await firebaseSignOut(auth);
                throw new Error("Access denied: Admin account must be linked to a church.");
            }
        } else {
            // Other roles: Access denied
            await firebaseSignOut(auth);
            throw new Error("Access denied: You do not have administrator privileges.");
        }

        const token = await user.getIdToken();
        return { user, token };
    } catch (error) {
        console.error("Error signing in", error);
        throw error;
    }
}

export async function signOut() {
    try {
        await firebaseSignOut(auth);
    } catch (error) {
        console.error("Error signing out", error);
        throw error;
    }
}
