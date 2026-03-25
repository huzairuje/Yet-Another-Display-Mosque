import { eventManager } from '$lib/server/events';

export const GET = async () => {
	let interval: NodeJS.Timeout;

	const stream = new ReadableStream({
		start(controller) {
			// Pas ada update, kirim ke browser
			const unsubscribe = eventManager.subscribe(() => {
				try {
					controller.enqueue(`data: update\n\n`);
				} catch (e) {
					// Kalo error (pipa tutup), ya sutralah
				}
			});

			// Kirim ping tiap 20 detik biar koneksi gak drop
			interval = setInterval(() => {
				try {
					controller.enqueue(`: ping\n\n`);
				} catch (e) {
					// Kalo error, stop intervalnya bre!
					clearInterval(interval);
				}
			}, 20000);

			// Kita butuh cara buat bersihin pas stream-nya cancel
			(controller as any).unsubscribe = unsubscribe;
		},
		cancel(controller) {
			if (interval) clearInterval(interval);
			if ((controller as any).unsubscribe) (controller as any).unsubscribe();
		}
	});

	return new Response(stream, {
		headers: {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			Connection: 'keep-alive'
		}
	});
};
