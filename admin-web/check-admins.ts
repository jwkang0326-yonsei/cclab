
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const projectId = 'cclab-4ec42';
initializeApp({
  projectId: projectId
});

const db = getFirestore();

async function checkAdmins() {
  const usersRef = db.collection('users');
  const snapshot = await usersRef.where('role', 'in', ['super-admin', 'admin']).get();
  
  if (snapshot.empty) {
    console.log('No admins found.');
    return;
  }

  snapshot.forEach(doc => {
    console.log(`${doc.id} => `, doc.data());
  });
}

checkAdmins().catch(console.error);
