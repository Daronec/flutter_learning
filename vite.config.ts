import { defineConfig } from 'vite';

export default defineConfig({
  // Vite transforms TSX through esbuild; keeping the config plugin-free
  // makes the local preview independent of Babel's browser-target database.
});
