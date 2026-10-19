import { execSync } from 'child_process';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { cp, readdir } from 'fs/promises';
import { existsSync } from 'fs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoDir = resolve(__dirname, '../../daronec.github.io');
const distDir = resolve(__dirname, '../dist');

console.log('Building site...');
execSync('npm run build', { stdio: 'inherit' });

console.log('Deploying to daronec.github.io...');

if (!existsSync(repoDir)) {
  console.log('Cloning daronec.github.io...');
  execSync(`git clone https://github.com/Daronec/daronec.github.io.git "${repoDir}"`, { stdio: 'inherit' });
}

// Copy files
const files = await readdir(distDir);
for (const file of files) {
  const src = resolve(distDir, file);
  const dest = resolve(repoDir, file);
  await cp(src, dest, { recursive: true, force: true });
  console.log(`  Copied: ${file}`);
}

// Commit and push
execSync('git add .', { cwd: repoDir, stdio: 'inherit' });
execSync('git commit -m "Deploy Flutter Learning site"', { cwd: repoDir, stdio: 'inherit' });
execSync('git push', { cwd: repoDir, stdio: 'inherit' });

console.log('Deploy complete! https://daronec.github.io');
