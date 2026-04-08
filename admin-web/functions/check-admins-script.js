
const admin = require('firebase-admin');

// Service account is not strictly needed if we are using ADC or running where it is configured
// But since we have a service account file in the parent, let's try to find it or use default
const serviceAccount = require('../../app/cclab-490708-8f647a546419.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'cclab-4ec42' // Override just in case
});

const db = admin.firestore();

async function checkAdmins() {
  const usersRef = db.collection('users');
  const snapshot = await usersRef.where('role', 'in', ['super-admin', 'admin']).get();
  
  if (snapshot.empty) {
    console.log('No admins found in Firestore "users" collection.');
    return;
  }

  snapshot.forEach(doc => {
    console.log(`${doc.id} => email: ${doc.data().email}, role: ${doc.data().role}`);
  });
}

checkAdmins().catch(console.error);
