import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:with_bible/data/repositories/user_repository.dart';
import 'package:with_bible/data/models/user_model.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late UserRepository userRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    // Mock Firestore structure: collection('users').doc(uid)
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);

    userRepository = UserRepository(firestore: mockFirestore);
  });

  group('UserRepository', () {
    const tUid = 'test-uid';
    const tUser = UserModel(
      uid: tUid,
      email: 'test@example.com',
      name: 'Test User',
      churchId: null,
      role: 'member',
    );

    test('createUser should set data in Firestore', () async {
      when(() => mockDocument.set(any(), any())).thenAnswer((_) async {});

      await userRepository.createUser(tUser);

      // Verify that set is called with the correct data. 
      // We use any() for SetOptions to avoid equality issues with external classes.
      verify(() => mockDocument.set(tUser.toJson(), any())).called(1);
    });

    test('getUser should return UserModel when data exists', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(tUser.toJson());
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);

      final result = await userRepository.getUser(tUid);

      expect(result, equals(tUser));
    });
  });
}