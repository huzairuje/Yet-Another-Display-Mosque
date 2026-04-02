import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
	plugins: [sveltekit(), tailwindcss()],
	server: {
		watch: {
			// Kasih tau Vite jangan mantau folder data/ biar gak refresh pas simpan settings
			ignored: ['**/data/**']
		},
		proxy: {
			'/api': 'http://127.0.0.1:3000',
			'/uploads': 'http://127.0.0.1:3000'
		}
	},
	ssr: {
		noExternal: ['adhan', 'lucide-svelte']
	}
});
