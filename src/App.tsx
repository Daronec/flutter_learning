import { useEffect, useMemo, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import {
  getCatalog,
  getChapter,
  getChapterLessons,
  getLesson
} from './content/store';
import type { Lesson } from './types/content';
import './styles.css';

type Route =
  | { type: 'home' }
  | { type: 'chapter'; chapterId: string }
  | { type: 'lesson'; chapterId: string; lessonId: string }
  | { type: 'interview' };

const catalog = getCatalog();

function readRoute(): Route {
  const parts = window.location.hash.replace(/^#\/?/, '').split('/').filter(Boolean);
  if (parts[0] === 'interview') {
    return { type: 'interview' };
  }
  if (parts[0] === 'chapter' && parts[1] && parts[2] === 'lesson' && parts[3]) {
    return {
      type: 'lesson',
      chapterId: decodeURIComponent(parts[1]),
      lessonId: decodeURIComponent(parts[3])
    };
  }
  if (parts[0] === 'chapter' && parts[1]) {
    return { type: 'chapter', chapterId: decodeURIComponent(parts[1]) };
  }
  return { type: 'home' };
}

function linkForChapter(chapterId: string) {
  return `#/chapter/${encodeURIComponent(chapterId)}`;
}

function linkForLesson(chapterId: string, lessonId: string) {
  return `${linkForChapter(chapterId)}/lesson/${encodeURIComponent(lessonId)}`;
}

function Header() {
  return (
    <header className="site-header">
      <a className="brand" href="#/">
        <span className="brand-mark">📚</span>
        <span>
          <strong>Flutter Learning</strong>
          <small>Учебный курс по Flutter и Dart</small>
        </span>
      </a>
    </header>
  );
}

function HomePage() {
  return (
    <>
      <section className="hero">
        <p className="eyebrow">Путь разработчика</p>
        <h1>Изучайте Flutter последовательно</h1>
        <p>От основ Dart и виджетов до архитектуры, тестирования и публикации приложений.</p>
      </section>
      <section className="interview-cta" aria-label="Подготовка к собеседованию">
        <a className="interview-card" href="#/interview">
          <span className="interview-card-icon">🎯</span>
          <div className="interview-card-text">
            <strong>100 вопросов Flutter к собеседованию</strong>
            <small>Полный список вопросов и ответов на русском языке</small>
          </div>
          <span className="interview-card-arrow">→</span>
        </a>
      </section>
      <section className="chapter-grid" aria-label="Главы курса">
        {catalog.chapters.map((chapter) => {
          const lessons = getChapterLessons(chapter.id);
          return (
            <a className="chapter-card" href={linkForChapter(chapter.id)} key={chapter.id}>
              <div className="chapter-card-top">
                <span className="chapter-icon">{chapter.icon}</span>
                <span className="chapter-number">{String(chapter.number).padStart(2, '0')}</span>
              </div>
              <h2>{chapter.title}</h2>
              <p>{chapter.description}</p>
              <span className="chapter-card-footer">{lessons.length} уроков <span>→</span></span>
            </a>
          );
        })}
      </section>
    </>
  );
}

function ChapterPage({ chapterId }: { chapterId: string }) {
  const chapter = getChapter(chapterId);
  const lessons = getChapterLessons(chapterId);

  return (
    <section>
      <a className="back-link" href="#/">← Все главы</a>
      <div className="chapter-heading">
        <span className="chapter-icon large">{chapter.icon}</span>
        <div>
          <p className="eyebrow">Глава {chapter.number}</p>
          <h1>{chapter.title}</h1>
          <p>{chapter.description}</p>
        </div>
      </div>
      <div className="lesson-list">
        {lessons.map((lesson) => (
          <a className="lesson-row" href={linkForLesson(chapterId, lesson.id)} key={lesson.id}>
            <span className="lesson-number">{chapter.number}.{lesson.order}</span>
            <span className="lesson-row-content">
              <strong>{lesson.title}</strong>
              {lesson.summary && <small>{lesson.summary}</small>}
            </span>
            <span className="lesson-arrow">→</span>
          </a>
        ))}
      </div>
    </section>
  );
}

function LessonPage({ chapterId, lessonId }: { chapterId: string; lessonId: string }) {
  const chapter = getChapter(chapterId);
  const lessons = getChapterLessons(chapterId);
  const lesson = getLesson(chapterId, lessonId);
  const index = lessons.findIndex((item) => item.id === lessonId);
  const previous = index > 0 ? lessons[index - 1] : undefined;
  const next = index < lessons.length - 1 ? lessons[index + 1] : undefined;

  return (
    <article className="lesson-page">
      <div className="lesson-topbar">
        <a className="back-link" href={linkForChapter(chapterId)}>← {chapter.title}</a>
        <span className="lesson-progress">{index + 1} / {lessons.length}</span>
      </div>
      <div className="lesson-title-block">
        <p className="eyebrow">Глава {chapter.number} · Урок {lesson.order}</p>
        <h1>{lesson.title}</h1>
        {lesson.summary && <p className="lesson-summary">{lesson.summary}</p>}
      </div>
      <div className="lesson-body">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{lesson.content}</ReactMarkdown>
      </div>
      <nav className="lesson-navigation" aria-label="Навигация по урокам">
        {previous ? <a href={linkForLesson(chapterId, previous.id)}>← {previous.title}</a> : <span />}
        {next ? <a className="next-link" href={linkForLesson(chapterId, next.id)}>{next.title} →</a> : <span />}
      </nav>
    </article>
  );
}

function InterviewPage() {
  const [content, setContent] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('/questions.md')
      .then((res) => {
        if (!res.ok) throw new Error('Не удалось загрузить вопросы');
        return res.text();
      })
      .then((text) => setContent(text))
      .catch((err) => setError(err.message));
  }, []);

  if (error) {
    return (
      <article className="interview-page">
        <div className="interview-topbar">
          <a className="back-link" href="#/">← На главную</a>
        </div>
        <p className="interview-error">Ошибка: {error}</p>
      </article>
    );
  }

  return (
    <article className="interview-page">
      <div className="interview-topbar">
        <a className="back-link" href="#/">← На главную</a>
        <span className="interview-badge">100 вопросов</span>
      </div>
      <div className="interview-title-block">
        <p className="eyebrow">Подготовка к собеседованию</p>
        <h1>Flutter &amp; Dart — 100 вопросов с ответами</h1>
        <p className="interview-summary">Комплексный справочник по самым частым вопросам на собеседованиях на позицию Flutter-разработчика.</p>
      </div>
      <div className="interview-body">
        {content ? (
          <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
        ) : (
          <p>Загрузка...</p>
        )}
      </div>
    </article>
  );
}

function ErrorPage({ error }: { error: Error }) {
  return (
    <section className="error-page">
      <p className="eyebrow">Ошибка загрузки</p>
      <h1>Не удалось открыть страницу</h1>
      <p>{error.message}</p>
      <a className="button-link" href="#/">На главную</a>
    </section>
  );
}

function App() {
  const [route, setRoute] = useState<Route>(readRoute);

  useEffect(() => {
    const handleHashChange = () => setRoute(readRoute());
    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  const page = useMemo(() => {
    try {
      if (route.type === 'interview') return <InterviewPage />;
      if (route.type === 'chapter') return <ChapterPage chapterId={route.chapterId} />;
      if (route.type === 'lesson') return <LessonPage chapterId={route.chapterId} lessonId={route.lessonId} />;
      return <HomePage />;
    } catch (error) {
      return <ErrorPage error={error instanceof Error ? error : new Error('Unknown error')} />;
    }
  }, [route]);

  return (
    <div className="app-shell">
      <Header />
      <main>{page}</main>
      <footer>Flutter Learning · React migration</footer>
    </div>
  );
}

export default App;
