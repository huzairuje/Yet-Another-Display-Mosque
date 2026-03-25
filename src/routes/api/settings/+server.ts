import { json } from '@sveltejs/kit';
import fs from 'fs';
import path from 'path';

// Kita simpen di folder data/settings.json
const DATA_PATH = path.resolve('data/settings.json');

// Helper buat baca data
const readSettings = () => {
	try {
		const data = fs.readFileSync(DATA_PATH, 'utf-8');
		return JSON.parse(data);
	} catch (e) {
		console.error('Gagal baca settings.json:', e);
		return null;
	}
};

// GET: Ambil data settings
export const GET = async () => {
	const data = readSettings();
	if (!data) return json({ error: 'Gagal muat data' }, { status: 500 });
	return json(data);
};

import { eventManager } from '$lib/server/events';

// POST: Update data settings
export const POST = async ({ request }) => {
	try {
		const newSettings = await request.json();
		fs.writeFileSync(DATA_PATH, JSON.stringify(newSettings, null, 2));

		// Teriak ke semua TV: "Woi, ada update nih!"
		eventManager.publish('update');

		return json({ success: true });
	} catch (e) {
		console.error('Gagal simpan settings.json:', e);
		return json({ error: 'Gagal simpan data' }, { status: 500 });
	}
};
