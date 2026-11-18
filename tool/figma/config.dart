/// Fixed Figma coordinates for "ClassMeet – Official" and local cache paths.
library;

const fileKey = 'NsPDhVmXnmtaCLIvtHaJTp';
const apiBase = 'https://api.figma.com/v1';

/// Section label → section node id (Page 1).
const sections = {
  'onboarding': '5444:10018',
  'home': '5442:9758',
  'study': '5442:10636',
  'create': '5444:10921',
  'play': '5453:13880',
};

const designSystemPage = '5248:351';
const draftsPage = '5175:159';

/// Local caches (all gitignored under design/).
const figmaDir = 'design/figma';
const nodesDir = '$figmaDir/nodes';
const imagesDir = '$figmaDir/images';
const requestLog = '$figmaDir/requests.log';
const refDir = 'design/ref';
const specsDir = 'design/specs';
const framesCsv = 'design/frames.csv';
const inventoryPath = 'design/notes/screen_inventory.md';
const trackerPath = 'DEV_TRACKER.md';

String nodesCachePath(String label) => '$nodesDir/$label.json';
String imageUrlsCachePath(String label, num scale, String format) =>
    '$imagesDir/$label@${scale}x.$format.json';
String imageFilePath(String label, String id, num scale, String format) =>
    '$imagesDir/$label/${safeId(id)}@${scale}x.$format';

/// Node ids contain `:`, which Windows file names can't.
String safeId(String id) => id.replaceAll(':', '-');
