
import { initializeApp } from "firebase/app";

// This test should fail if firebase is not installed or configured
try {
  const app = initializeApp({});
  console.log("Firebase initialized");
} catch (e) {
  console.error("Firebase initialization failed as expected:", e);
  process.exit(1); 
}
