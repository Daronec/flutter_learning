export interface ChapterMeta {
  id: string;
  number: number;
  title: string;
  description: string;
  icon: string;
  order: number;
  lessonsFile: string;
}

export interface Catalog {
  schemaVersion: number;
  chapters: ChapterMeta[];
}

export interface LessonMeta {
  id: string;
  slug: string;
  title: string;
  order: number;
  file: string;
  summary: string | null;
  tags: string[];
}

export interface LessonsManifest {
  schemaVersion: number;
  chapterId: string;
  lessons: LessonMeta[];
}

export interface Lesson extends LessonMeta {
  chapterId: string;
  content: string;
}
