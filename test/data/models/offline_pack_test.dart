import 'package:classmeet/data/models/offline_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OfflinePack copyWith', () {
    const p = OfflinePack(
      id: 'p',
      title: 'ITE 13',
      contentsLabel: 'Reviewers',
      sizeBytes: 5,
    );
    final c = p.copyWith();
    expect(
      [c.id, c.title, c.contentsLabel, c.sizeBytes],
      ['p', 'ITE 13', 'Reviewers', 5],
    );
    final d = p.copyWith(sizeBytes: 9);
    expect(d.sizeBytes, 9);
    expect(d.title, 'ITE 13');
  });

  test('StorageUsage fraction', () {
    const u = StorageUsage(usedBytes: 120, totalBytes: 500);
    expect(u.fraction, closeTo(0.24, 1e-9));
    expect(u.copyWith().usedBytes, 120);
    expect(u.copyWith().totalBytes, 500);
    expect(u.copyWith(totalBytes: 0).fraction, 0);
    expect(u.copyWith(usedBytes: 900).fraction, 1);
  });

  test('DownloadSettings', () {
    const s = DownloadSettings();
    expect(s.wifiOnly, isTrue);
    expect(s.autoDownload, isTrue);
    expect(s.copyWith().wifiOnly, isTrue);
    final c = s.copyWith(wifiOnly: false);
    expect(c.wifiOnly, isFalse);
    expect(c.autoDownload, isTrue);
  });
}
