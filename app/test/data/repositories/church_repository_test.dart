import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:with_bible/data/repositories/church_repository.dart';
import 'package:with_bible/data/models/church_model.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late ChurchRepository churchRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockSnapshot;
  late MockQueryDocumentSnapshot mockDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockSnapshot = MockQuerySnapshot();
    mockDoc = MockQueryDocumentSnapshot();

    when(() => mockFirestore.collection('churches')).thenReturn(mockCollection);
    churchRepository = ChurchRepository(firestore: mockFirestore);
  });

  group('ChurchRepository', () {
    const tCode = 'TEST1234';
    const tChurch = ChurchModel(
      id: 'church-1',
      name: 'Test Church',
      inviteCode: tCode,
    );

    test('verifyCode should return ChurchModel if code exists', () async {
      // Setup Query: collection('churches').where('invite_code', isEqualTo: code).limit(1).get()
      when(() => mockCollection.where('invite_code', isEqualTo: tCode)).thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      
      // Setup Snapshot
      when(() => mockSnapshot.docs).thenReturn([mockDoc]);
      when(() => mockDoc.data()).thenReturn(tChurch.toJson());
      when(() => mockDoc.id).thenReturn(tChurch.id); // Add ID if needed manually or inside toJson

      final result = await churchRepository.verifyCode(tCode);

      expect(result, equals(tChurch));
    });

    test('verifyCode should return null if code does not exist', () async {
      when(() => mockCollection.where('invite_code', isEqualTo: 'INVALID')).thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      
      when(() => mockSnapshot.docs).thenReturn([]); // Empty list

      final result = await churchRepository.verifyCode('INVALID');

      expect(result, isNull);
    });
  });
}
