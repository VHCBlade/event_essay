import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_essay/event_essay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Url Launcher Repository", () {
    group("prefixIfNecessary", prefixTest);
  });
}

Map<String, List<String> Function()> get commonTestCases => {
      "Without https://": () => [
            "reviewerblade.com",
            "example.com",
            "cool.io",
            "vhcblade.com/#/apps",
          ],
      "With https://": () =>
          ["https://reviewer.vhcblade.com", "https://vhcblade.com/#/apps"],
      "With ftp://": () => ["ftp://example.com", "ftp://vhcblade.com"],
      "With mailto:": () => [
            "mailto:test@example.com",
            "mailto:123@example.com",
            "mailto:great",
          ]
    };

void prefixTest() {
  final tester = SerializableListTester<List<String>>(
    testGroupName: "Url Launcher Repository",
    mainTestName: "prefixIfNecessary",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) {
      final repo = UrlLauncherRepository();
      value.forEach(
          (element) => tester.addTestValue(repo.prefixIfNecessary(element)));
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}
