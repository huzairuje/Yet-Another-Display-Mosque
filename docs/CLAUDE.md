# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Al-Ye'AnDiMo** (Alhamdulillah It's Yet Another Display Mosque) is a modern mosque display system for showing prayer times, announcements, and information on 1080p screens. The system features real-time synchronization between an admin panel and the main display using Server-Sent Events (SSE).

**Tech Stack:**
- **Frontend**: SvelteKit + Svelte 5 (Runes), TailwindCSS, TypeScript
- **Backend**: Go 1.24+ with Echo framework
- **Prayer Calculation**: `adhan` library
- **Real-time Sync**: Server-Sent Events (SSE)
- **Package Manager**: pnpm

## Development Commands

### Frontend Development
```bash
# Install dependencies
pnpm install

# Run development server (Vite dev server on port 5173)
pnpm dev

# Build SvelteKit static site (outputs to ./build)
pnpm build

# Preview production build
pnpm preview

# Type checking
pnpm check

# Type checking with watch mode
pnpm check:watch

# Lint code (Prettier + ESLint)
pnpm lint

# Format code
pnpm format
```

### Backend Development
```bash
# Build Go backend for current platform
go build -o server cmd/server/main.go

# Run Go backend (serves static build + API)
./server

# Build for Linux
GOOS=linux GOARCH=amd64 go build -o server cmd/server/main.go

# Build for Windows
GOOS=windows GOARCH=amd64 go build -o server.exe cmd/server/main.go
```

### Full Build (Production Runner Packages)
```bash
# Build complete runner packages for Linux and Windows
bash build.sh
```

This script:
1. Cleans old builds
2. Runs `pnpm build` to create static SvelteKit build
3. Builds Go backend for Linux and Windows
4. Copies build artifacts, data, and static files to `runner/linux` and `runner/windows`
5. Creates startup scripts (`start.sh` for Linux, `start.bat` for Windows)

## Architecture

### Application Structure

```
cmd/server/main.go          # Go backend with Echo server
src/
  lib/
    settings.svelte.ts      # Settings store (Svelte 5 Runes)
    prayer.svelte.ts        # Prayer calculation service
    components/             # Reusable Svelte components
    utils/                  # Utility functions
  routes/
    +page.svelte           # Main display (TV screen)
    +layout.svelte         # Root layout with theme system
    admin/+page.svelte     # Admin panel
    kas/+page.svelte       # Cash management (beta)
data/settings.json         # Persistent settings storage
static/uploads/            # User-uploaded background images
```

### Backend (Go + Echo)

The Go backend (`cmd/server/main.go`) serves as a lightweight API server and static file server:

**API Endpoints:**
- `GET /api/settings` - Retrieve current settings from `data/settings.json`
- `POST /api/settings` - Update settings and trigger SSE event
- `GET /api/events` - SSE endpoint for real-time updates
- `POST /api/upload` - Upload background images (max 5MB, JPG/PNG/WEBP only)
- `DELETE /api/upload` - Delete uploaded images

**Static Serving:**
- `/uploads/*` - Serves uploaded images from `static/uploads/`
- `/*` - Serves pre-built SvelteKit static files from `build/` with SPA fallback

**Environment Variables:**
- `PORT` - Server port (default: 3000)
- `HOST` - Server host (default: 0.0.0.0)

### Frontend (SvelteKit + Svelte 5)

**State Management:**
Uses Svelte 5 Runes (`$state`, `$derived`, `$effect`) for reactive state:
- `settings.svelte.ts` - Global settings store, loads from `/api/settings`
- `prayer.svelte.ts` - Prayer times calculation, current time tracking, display mode transitions

**Real-time Sync (SSE):**
1. Admin panel updates settings via `POST /api/settings`
2. Backend saves to `data/settings.json` and publishes "update" event
3. Main display receives SSE event and reloads settings
4. UI updates reactively via Svelte Runes

**Routes:**
- `/` - Main display for TV screens (prayer times, announcements, slideshow)
- `/admin` - Admin panel for configuration (password protected)
- `/kas` - Cash management interface (beta feature)

**Build Configuration:**
- Uses `@sveltejs/adapter-static` to generate static HTML/JS/CSS
- SPA mode with `fallback: 'index.html'` for client-side routing
- Outputs to `build/` directory

### Data Persistence

All settings are stored in `data/settings.json` including:
- Location coordinates (lat/lng) for prayer calculation
- Prayer time offsets and iqomah delays
- Theme selection and display durations
- Running text and announcements
- Cash transactions (beta)
- Admin password
- Background image paths

**Settings Interface** (see `src/lib/settings.svelte.ts`):
```typescript
interface Settings {
  lat: number;
  lng: number;
  offsets: { fajr, sunrise, dhuha, dhuhr, asr, maghrib, isha };
  iqomah: { fajr, dhuhr, asr, maghrib, isha };
  drift: number;
  cash: number;
  runningText: string;
  bigInfo: string;
  infos: InfoItem[];
  preAdzanDuration: number;
  sholatDuration: number;
  bgSlideshowDuration: number;
  infoSlideshowDuration: number;
  transactions: Transaction[];
  adminPassword: string;
  backgrounds: string[];
  fridayKhatib: string;
  // ... more fields
}
```

## Key Concepts

### Prayer Time Calculation
- Uses the `adhan` library for accurate Islamic prayer time calculation
- Requires latitude/longitude coordinates
- Supports custom offsets per prayer time
- Calculates Dhuha time separately (sunrise + 15 minutes by default)

### Display Modes
The main display transitions through different modes:
- **Normal** - Default display with prayer times and info
- **Pre-Adzan** - Countdown before adzan time
- **Adzan** - During adzan (call to prayer)
- **Iqomah** - Countdown to prayer start
- **Sholat** - During prayer time
- **Jumat** - Special Friday mode with khatib info
- **Khutbah** - Friday sermon timer

### Theme System
Dynamic themes controlled by time of day (vibe):
- Subuh (dawn), Pagi (morning), Siang (noon), Sore (afternoon), Maghrib (sunset), Malam (night)
- Multiple theme presets: Modern, Classic, Ocean, Sunset, etc.
- Themes affect gradients, fonts, and layout structure

## Development Workflow

### Making Changes to Frontend
1. Run `pnpm dev` for hot-reload development
2. Edit Svelte components in `src/`
3. Changes appear instantly in browser
4. Use `pnpm check` to verify TypeScript types
5. Run `pnpm lint` before committing

### Making Changes to Backend
1. Edit `cmd/server/main.go`
2. Rebuild: `go build -o server cmd/server/main.go`
3. Restart server: `./server`
4. Test API endpoints with curl or browser

### Testing Full Integration
1. Build frontend: `pnpm build`
2. Build backend: `go build -o server cmd/server/main.go`
3. Run backend: `./server`
4. Open browser to `http://localhost:3000`
5. Test admin panel at `http://localhost:3000/admin`
6. Verify SSE sync by opening main display and admin panel simultaneously

### Creating Release Packages
```bash
bash build.sh
```
This creates ready-to-deploy packages in `runner/linux/` and `runner/windows/` with all dependencies bundled.

## Important Notes

- **SvelteKit Adapter**: Uses `adapter-static` for static site generation, not SSR
- **Svelte 5 Runes**: All state management uses new Runes API (`$state`, `$derived`, `$effect`)
- **No Node.js in Production**: The Go backend serves static files, no Node.js runtime needed
- **Settings Persistence**: All data in `data/settings.json` - back up this file regularly
- **Image Uploads**: Stored in `static/uploads/`, included in runner packages
- **SSE Connection**: Main display maintains persistent connection to `/api/events`
- **Admin Password**: Stored in plain text in settings.json (consider hashing for production)

## Troubleshooting

**Frontend not updating after settings change:**
- Check browser console for SSE connection errors
- Verify `/api/events` endpoint is accessible
- Check backend logs for event publishing

**Prayer times incorrect:**
- Verify lat/lng coordinates in settings
- Check timezone/drift settings
- Inspect `prayer.svelte.ts` calculation logic

**Build fails:**
- Ensure pnpm is installed: `npm install -g pnpm`
- Clear cache: `rm -rf node_modules .svelte-kit && pnpm install`
- Check Go version: `go version` (requires 1.24+)

**Backend won't start:**
- Check if port 3000 is already in use
- Verify `build/` directory exists (run `pnpm build` first)
- Ensure `data/` directory has write permissions
