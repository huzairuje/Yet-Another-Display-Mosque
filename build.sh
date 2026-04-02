#!/bin/bash

echo "🏗️  Memulai proses build YADM..."

# 1. Bersihin folder lama (biar fresh)
echo "🧹 Membersihkan folder lama..."
rm -rf build runner/linux runner/windows
mkdir -p runner/linux/data runner/linux/static
mkdir -p runner/windows/data runner/windows/static

# 2. Build SvelteKit (pake adapter-static)
echo "📦 Menjalankan pnpm build..."
pnpm build

# 3. Build Go Backend
echo "🐹 Menjalankan go build..."
# Build for Linux
GOOS=linux GOARCH=amd64 go build -o runner/linux/server cmd/server/main.go
# Build for Windows
GOOS=windows GOARCH=amd64 go build -o runner/windows/server.exe cmd/server/main.go

# 4. Copy hasil build ke masing-masing folder runner
echo "📂 Menyalin hasil build ke folder runner..."
cp -r build runner/linux/
cp -r build runner/windows/

# 5. Copy folder data (settings)
echo "⚙️  Menyalin folder data..."
cp -r data/* runner/linux/data/
cp -r data/* runner/windows/data/

# 6. Copy folder static (uploads/images)
echo "🖼️  Menyalin folder static..."
cp -r static/* runner/linux/static/
cp -r static/* runner/windows/static/

# 7. Bikin Runner Script - Linux
echo "📜 Membuat script runner Linux..."
cat <<EOF > runner/linux/start.sh
#!/bin/bash
PARENT_PATH=\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)
cd "\$PARENT_PATH"
echo "🚀 Menjalankan YADM dari folder runner..."
export PORT=3000
export HOST=0.0.0.0
./server
EOF
chmod +x runner/linux/start.sh

# 8. Bikin Runner Script - Windows
echo "📜 Membuat script runner Windows..."
cat <<EOF > runner/windows/start.bat
@echo off
title YADM - Yet Another Display Mosque Runner
cd /d %~dp0
echo 🚀 Menjalankan YADM dari folder runner...
set PORT=3000
set HOST=0.0.0.0
server.exe
pause
EOF

# 9. Bersihin folder build sementara
rm -rf build

echo "✅ Selesai bre! Cek folder ./runner/ buat hasilnya."
