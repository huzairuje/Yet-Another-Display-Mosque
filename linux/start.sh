#!/bin/bash
PARENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PARENT_PATH"
echo "🚀 Menjalankan YADM dari folder runner..."
export PORT=3000
export HOST=0.0.0.0
node build
