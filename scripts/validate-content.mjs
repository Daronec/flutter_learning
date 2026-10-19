import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const sourceRoot = path.join(projectRoot, 'knowledge');
const contentRoot = path.join(projectRoot, 'react-content');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const catalogPath = path.join(contentRoot, 'catalog.json');
assert(fs.existsSync(catalogPath), 'Missing react-content/catalog.json');

const catalog = readJson(catalogPath);
assert(catalog.schemaVersion === 1, 'Unsupported catalog schema version');
assert(Array.isArray(catalog.chapters), 'catalog.chapters must be an array');
assert(catalog.chapters.length === 16, `Expected 16 chapters, found ${catalog.chapters.length}`);

const chapterIds = new Set();
const lessonIds = new Set();
let lessonCount = 0;

for (const chapter of catalog.chapters) {
  assert(!chapterIds.has(chapter.id), `Duplicate chapter id: ${chapter.id}`);
  chapterIds.add(chapter.id);

  const chapterRoot = path.join(contentRoot, 'chapters', chapter.id);
  const lessonsPath = path.join(projectRoot, 'react-content', chapter.lessonsFile);
  assert(fs.existsSync(chapterRoot), `Missing chapter directory: ${chapter.id}`);
  assert(fs.existsSync(lessonsPath), `Missing lessons manifest: ${chapter.lessonsFile}`);

  const manifest = readJson(lessonsPath);
  assert(manifest.schemaVersion === 1, `Unsupported lesson schema in ${chapter.id}`);
  assert(manifest.chapterId === chapter.id, `Wrong chapterId in ${chapter.id}/lessons.json`);
  assert(Array.isArray(manifest.lessons), `lessons must be an array in ${chapter.id}`);

  for (const lesson of manifest.lessons) {
    assert(!lessonIds.has(lesson.id), `Duplicate lesson id: ${lesson.id}`);
    lessonIds.add(lesson.id);
    assert(Number.isInteger(lesson.order), `Invalid order for ${lesson.id}`);
    assert(lesson.title.length > 0, `Empty title for ${lesson.id}`);

    const targetPath = path.join(chapterRoot, lesson.file);
    const sourcePath = path.join(sourceRoot, chapter.id, path.basename(lesson.file));
    assert(fs.existsSync(targetPath), `Missing lesson content: ${chapter.id}/${lesson.file}`);
    assert(fs.existsSync(sourcePath), `Missing source lesson: ${chapter.id}/${path.basename(lesson.file)}`);
    assert(
      fs.readFileSync(targetPath, 'utf8') === fs.readFileSync(sourcePath, 'utf8'),
      `Content changed during migration: ${lesson.id}`
    );
    lessonCount += 1;
  }
}

assert(lessonCount === 145, `Expected 145 lessons, found ${lessonCount}`);
console.log(`Content validation passed: ${chapterIds.size} chapters, ${lessonIds.size} lessons.`);
