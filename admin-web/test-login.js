
import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
    apiKey: "AIzaSyBl59sRmxoYoDK1SnWmiYqFRBYpzg3Y384",
    authDomain: "cclab-4ec42.firebaseapp.com",
    projectId: "cclab-4ec42"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

async function testLogin() {
    try {
        const userCredential = await signInWithEmailAndPassword(auth, "jwkang@ohmyplay.com", "cclab!23");
        console.log("LOGIN_SUCCESS: User logged in successfully!", userCredential.user.uid);
    } catch (error) {
        console.error("LOGIN_FAILED:", error.code, error.message);
    }
}

testLogin();
