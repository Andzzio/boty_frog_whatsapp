import 'package:boty_frog/core/debounce_manager.dart';
import 'package:test/test.dart';

void main() {
  group('DebounceManager', () {
    setUp(DebounceManager.instance.clear);

    test('should invoke callback only once after the duration', () async {
      var callCount = 0;
      DebounceManager.instance.run(
        'user1',
        const Duration(milliseconds: 50),
        () {
          callCount++;
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(1));
    });

    test(
      'should reset the timer if a new call is made before duration',
      () async {
        var callCount = 0;
        DebounceManager.instance.run(
          'user1',
          const Duration(milliseconds: 100),
          () {
            callCount++;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(callCount, equals(0));

        DebounceManager.instance.run(
          'user1',
          const Duration(milliseconds: 100),
          () {
            callCount++;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(callCount, equals(0));

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(callCount, equals(1));
      },
    );
  });
}
