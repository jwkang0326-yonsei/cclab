
const admin = require('firebase-admin');

// 서비스 계정 파일 경로 (프로젝트 루트의 app/ 폴더에 있는 파일을 사용)
const serviceAccount = require('../../app/cclab-490708-8f647a546419.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'cclab-4ec42'
});

async function resetPassword() {
  const email = 'jwkang@ohmyplay.com';
  const newPassword = 'cclab!23';

  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(user.uid, {
      password: newPassword
    });
    console.log(`Successfully updated password for user: ${email}`);
  } catch (error) {
    console.error('Error updating password:', error);
  }
}

resetPassword();
