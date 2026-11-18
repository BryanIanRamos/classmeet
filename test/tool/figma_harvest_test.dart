import 'package:flutter_test/flutter_test.dart';

import '../../tool/figma/client.dart';
import '../../tool/figma/frames.dart';
import '../../tool/figma/spec.dart';

void main() {
  group('inventory', () {
    const markdown = '''
## 1. Onboarding (section 5444:10018). Flow
- **5444:10019 | 94 | splash_welcome | /splash | S.**
  - **Layout:** ignored
- **5444:10106 | 96 | (state of 3.1).** Titled "Create account"
## 5. Play and quiz (section 5453:13880).
- **5453:16458 | 999 | quiz_x | sheet over 124 | M.**
''';

    test('parses id, number, slug and route per section', () {
      final frames = parseInventory(markdown);
      expect(frames.keys, ['5444:10019', '5444:10106', '5453:16458']);

      final splash = frames['5444:10019']!;
      expect(
        [splash.section, splash.no, splash.slug, splash.route],
        ['onboarding', '94', 'splash_welcome', '/splash'],
      );
      expect(splash.fileStem, '94_splash_welcome');

      expect(frames['5444:10106']!.slug, 'state_of_3_1');
      // Non-path "routes" (sheets, overlays) are dropped.
      expect(frames['5453:16458']!.route, '');
      expect(frames['5453:16458']!.section, 'play');
    });

    test('csv rows quote fields that need it', () {
      const f = Frame(id: '1:2', section: 's', no: '1', slug: 'a,b');
      expect(f.toCsvRow(), '1:2,s,1,"a,b",,,');
    });
  });

  test('sectionFrames lists visible top-level frames with size', () {
    final response = {
      'nodes': {
        '1:1': {
          'document': {
            'id': '1:1',
            'children': [
              {
                'id': '1:2',
                'name': '94',
                'type': 'FRAME',
                'absoluteBoundingBox': {'width': 428, 'height': 926},
              },
              {'id': '1:3', 'name': 'note', 'type': 'TEXT'},
              {'id': '1:4', 'name': 'old', 'type': 'FRAME', 'visible': false},
            ],
          },
        },
      },
    };
    final frames = sectionFrames(response, '1:1');
    expect(frames.map((f) => (f.id, f.width, f.height)), [
      ('1:2', 428.0, 926.0),
    ]);
  });

  group('spec condenser', () {
    test('hexColor converts 0..1 channels', () {
      expect(hexColor({'r': 1, 'g': 0.5, 'b': 0, 'a': 1}), '#FF8000');
      expect(hexColor({'r': 0, 'g': 0, 'b': 0, 'a': 0.5}), '#00000080');
    });

    test('describes auto-layout frames, text, icons and instances', () {
      expect(
        describeNode({
          'type': 'FRAME',
          'name': 'Header',
          'absoluteBoundingBox': {'width': 428, 'height': 56},
          'layoutMode': 'HORIZONTAL',
          'paddingTop': 12,
          'paddingBottom': 12,
          'paddingLeft': 16,
          'paddingRight': 16,
          'itemSpacing': 10,
          'counterAxisAlignItems': 'CENTER',
          'fills': [
            {
              'type': 'SOLID',
              'color': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
            },
          ],
          'cornerRadius': 16,
        }),
        'FRAME "Header" 428×56 · row pad 12/16 gap 10 cross=center · '
        'fill #FFFFFF · r16',
      );

      expect(
        describeNode({
          'type': 'TEXT',
          'characters': 'Good evening',
          'style': {
            'fontFamily': 'Plus Jakarta Sans',
            'fontSize': 16,
            'lineHeightPx': 24,
            'fontWeight': 500,
          },
        }),
        'TEXT "Good evening" · Plus Jakarta Sans 16/24 w500',
      );

      expect(
        describeNode({
          'type': 'INSTANCE',
          'name': 'li:bell',
          'absoluteBoundingBox': {'width': 24, 'height': 24},
        }),
        'icon `li:bell` 24×24',
      );

      expect(
        describeNode({
          'type': 'INSTANCE',
          'name': 'Button',
          'absoluteBoundingBox': {'width': 380, 'height': 48},
          'componentProperties': {
            'Size#1:0': {'value': 'Large', 'type': 'VARIANT'},
          },
        }),
        'INSTANCE "Button" 380×48 · {Size=Large}',
      );
    });

    test('condenseFrame skips hidden nodes and collapses vector runs', () {
      final frame = {
        'id': '9:1',
        'name': 'Art',
        'type': 'FRAME',
        'absoluteBoundingBox': {'width': 100, 'height': 100},
        'children': [
          {
            'id': '9:2',
            'type': 'TEXT',
            'characters': 'Hidden',
            'visible': false,
          },
          for (var i = 0; i < 5; i++) {'id': '9:v$i', 'type': 'VECTOR'},
        ],
      };
      final md = condenseFrame(frame, title: '1 art');
      expect(md, startsWith('# 1 art'));
      expect(md, isNot(contains('Hidden')));
      expect(md, contains('VECTOR ×5 (illustration)'));
      expect(findNode(frame, '9:v3'), isNotNull);
    });
  });

  group('requests', () {
    test('nodes and images URLs carry ids, depth and scale', () {
      final nodes = nodesRequest('drafts', ['5175:159'], depth: 2);
      expect(nodes.uri.path, '/v1/files/NsPDhVmXnmtaCLIvtHaJTp/nodes');
      expect(nodes.uri.queryParameters, {'ids': '5175:159', 'depth': '2'});
      expect(nodes.cachePath, 'design/figma/nodes/drafts.json');

      final noDepth = nodesRequest('home', ['5442:9758']);
      expect(noDepth.uri.queryParameters.containsKey('depth'), isFalse);

      final images = imagesRequest('home', ['1:2', '1:3'], scale: 2);
      expect(images.uri.path, '/v1/images/NsPDhVmXnmtaCLIvtHaJTp');
      expect(images.uri.queryParameters, {
        'ids': '1:2,1:3',
        'scale': '2',
        'format': 'png',
      });
    });

    test('tracker log row goes at the end of the harvest table', () {
      const tracker = '''
- **REST:** 0 requests.

| Date | Channel | Endpoint and nodes | Requests | Result |
|---|---|---|---|---|
| 2026-11-18 | MCP | analysis | ~20 | limit reached |

## Design-gap register''';
      final updated = RequestLog.insertTrackerRow(tracker, '| new | row |');
      expect(updated, contains('- **REST:** 1 requests.'));
      expect(
        updated,
        contains('| limit reached |\n| new | row |\n\n## Design-gap register'),
      );
    });
  });
}
