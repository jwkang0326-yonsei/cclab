import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/data/repositories/group_repository.dart';
import '../../../lib/data/models/group_model.dart';
import '../../../lib/domain/usecases/create_group_usecase.dart';
import 'create_group_usecase_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  group('CreateGroupUseCase', () {
    late MockGroupRepository mockGroupRepository;
    late CreateGroupUseCase createGroupUseCase;

    setUp(() {
      mockGroupRepository = MockGroupRepository();
      createGroupUseCase = CreateGroupUseCase(mockGroupRepository);
    });

    test('should create group successfully', () async {
      // Arrange
      const churchId = 'church-1';
      const name = 'New Group';
      const leaderUid = 'user-1';
      const generatedId = 'group-123';

      when(mockGroupRepository.createGroup(any))
          .thenAnswer((_) async => generatedId);

      // Act
      final result = await createGroupUseCase.execute(
        churchId: churchId,
        name: name,
        leaderUid: leaderUid,
      );

      // Assert
      expect(result, generatedId);
      verify(mockGroupRepository.createGroup(any)).called(1);
    });

    test('should throw exception if name is empty', () async {
      // Act & Assert
      expect(
        () => createGroupUseCase.execute(
          churchId: 'church-1',
          name: '',
          leaderUid: 'user-1',
        ),
        throwsException,
      );
    });
  });
}
