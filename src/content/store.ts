import catalogJson from '../../react-content/catalog.json';
import type {
  Catalog,
  ChapterMeta,
  Lesson,
  LessonsManifest
} from '../types/content';

const catalog = catalogJson as Catalog;

const manifestModules = import.meta.glob<LessonsManifest>(
  '../../react-content/chapters/*/lessons.json',
  { eager: true, import: 'default' }
);

const lessonModules = import.meta.glob<string>(
  '../../react-content/chapters/*/content/*.md',
  { eager: true, query: '?raw', import: 'default' }
);

const manifests = Object.values(manifestModules);

function chapterManifest(chapterId: string): LessonsManifest {
  const manifest = manifests.find((item) => item.chapterId === chapterId);
  if (!manifest) throw new Error(`Unknown chapter: ${chapterId}`);
  return manifest;
}

export function getCatalog(): Catalog {
  return catalog;
}

export function getChapter(chapterId: string): ChapterMeta {
  const chapter = catalog.chapters.find((item) => item.id === chapterId);
  if (!chapter) throw new Error(`Unknown chapter: ${chapterId}`);
  return chapter;
}

export function getChapterLessons(chapterId: string) {
  return [...chapterManifest(chapterId).lessons].sort((a, b) => a.order - b.order);
}

export function getLesson(chapterId: string, lessonId: string): Lesson {
  const meta = getChapterLessons(chapterId).find((item) => item.id === lessonId);
  if (!meta) throw new Error(`Unknown lesson: ${chapterId}/${lessonId}`);

  const lessonKey = `../../react-content/chapters/${chapterId}/${meta.file}`;
  const content = lessonModules[lessonKey];
  if (!content) throw new Error(`Missing lesson content: ${lessonKey}`);

  return { ...meta, chapterId, content };
}
