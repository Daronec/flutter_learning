import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const sourceRoot = path.join(projectRoot, 'knowledge');
const targetRoot = path.join(projectRoot, 'react-content');

const chapters = [
  ['chapter-01', 1, 'Введение в Flutter', 'История, архитектура и первые шаги с Flutter', '🚀'],
  ['chapter-02', 2, 'Основы Dart', 'Синтаксис, ООП, асинхронность и коллекции', '🎯'],
  ['chapter-03', 3, 'Виджеты', 'Виджеты, дерево элементов и жизненный цикл', '🧩'],
  ['chapter-04', 4, 'Основные виджеты', 'Container, Text, Icon, Row, Column, Stack, ListView и другие', '📦'],
  ['chapter-05', 5, 'Система layout', 'Flex, constraints, кастомные layout и адаптивный дизайн', '📐'],
  ['chapter-06', 6, 'Управление состоянием', 'State, Provider, Riverpod, BLoC и другие подходы', '⚡'],
  ['chapter-07', 7, 'Навигация', 'Navigator, маршрутизация, переходы и deep links', '🧭'],
  ['chapter-08', 8, 'Формы', 'Валидация, типы полей, date picker и отправка форм', '📝'],
  ['chapter-09', 9, 'Работа с API', 'HTTP, Dio, JSON, REST и GraphQL', '🌐'],
  ['chapter-10', 10, 'Локальное хранение данных', 'SharedPreferences, SQLite, Hive, Isar и secure storage', '💾'],
  ['chapter-11', 11, 'Чистая архитектура', 'Clean Architecture, Repository и Dependency Injection', '🏗️'],
  ['chapter-12', 12, 'Анимации', 'Implicit/explicit-анимации, Lottie и Rive', '🎬'],
  ['chapter-13', 13, 'Тестирование', 'Unit, widget, integration и golden tests', '🧪'],
  ['chapter-14', 14, 'Производительность', 'DevTools, профилирование и оптимизация', '⚡'],
  ['chapter-15', 15, 'Сборка приложения', 'APK, AAB, подпись и CI/CD', '📱'],
  ['chapter-16', 16, 'Platform Channels', 'Взаимодействие с нативным кодом Android и iOS', '🔌']
].map(([id, number, title, description, icon]) => ({
  id,
  number,
  title,
  description,
  icon,
  order: number,
  lessonsFile: `chapters/${id}/lessons.json`
}));

function ensureDirectory(directory) {
  fs.mkdirSync(directory, { recursive: true });
}

function writeJson(filePath, value) {
  ensureDirectory(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function stripInlineMarkdown(value) {
  return value
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
    .replace(/[`*_~]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function extractTitle(markdown, fallback) {
  const heading = markdown.split(/\r?\n/).find((line) => /^#\s+/.test(line.trim()));
  return heading ? stripInlineMarkdown(heading.trim().replace(/^#\s+/, '')) : fallback;
}

function extractSummary(markdown) {
  const lines = markdown.split(/\r?\n/);
  let insideCode = false;

  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('```')) {
      insideCode = !insideCode;
      continue;
    }
    if (insideCode || !trimmed || /^#{1,6}\s+/.test(trimmed)) continue;
    if (/^[-*+]\s+/.test(trimmed) || /^\d+\.\s+/.test(trimmed) || trimmed.startsWith('|')) continue;

    const summary = stripInlineMarkdown(trimmed);
    return summary.length > 240 ? `${summary.slice(0, 237).trimEnd()}...` : summary;
  }

  return null;
}

function lessonFromFile(chapter, fileName) {
  const match = fileName.match(/^(\d+)-(\d+)-(.+)\.md$/);
  if (!match) {
    throw new Error(`Unexpected lesson filename: ${chapter.id}/${fileName}`);
  }

  const sourcePath = path.join(sourceRoot, chapter.id, fileName);
  const markdown = fs.readFileSync(sourcePath, 'utf8');
  const baseName = fileName.replace(/\.md$/, '');

  return {
    id: baseName,
    slug: match[3],
    title: extractTitle(markdown, stripInlineMarkdown(match[3].replace(/-/g, ' '))),
    order: Number(match[2]),
    file: `content/${fileName}`,
    summary: extractSummary(markdown),
    tags: []
  };
}

if (fs.existsSync(path.join(targetRoot, 'catalog.json'))) {
  throw new Error(`${targetRoot} already contains catalog.json. Remove the generated content only if you intend to regenerate the migration.`);
}

ensureDirectory(targetRoot);
writeJson(path.join(targetRoot, 'catalog.json'), {
  schemaVersion: 1,
  chapters
});

let lessonCount = 0;

for (const chapter of chapters) {
  const sourceChapterRoot = path.join(sourceRoot, chapter.id);
  const targetChapterRoot = path.join(targetRoot, 'chapters', chapter.id);
  const targetContentRoot = path.join(targetChapterRoot, 'content');
  const markdownFiles = fs.readdirSync(sourceChapterRoot)
    .filter((fileName) => fileName.endsWith('.md'))
    .sort();

  const lessons = markdownFiles.map((fileName) => {
    const sourcePath = path.join(sourceChapterRoot, fileName);
    const targetPath = path.join(targetContentRoot, fileName);
    ensureDirectory(targetContentRoot);
    fs.writeFileSync(targetPath, fs.readFileSync(sourcePath, 'utf8'), 'utf8');
    lessonCount += 1;
    return lessonFromFile(chapter, fileName);
  });

  writeJson(path.join(targetChapterRoot, 'lessons.json'), {
    schemaVersion: 1,
    chapterId: chapter.id,
    lessons
  });
}

console.log(`Migrated ${chapters.length} chapters and ${lessonCount} lessons to react-content/.`);
