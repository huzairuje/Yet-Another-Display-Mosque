// Kita pake singleton sederhana buat nyimpen list koneksi yang lagi standby
class EventManager {
	private subscribers = new Set<(data: string) => void>();

	subscribe(callback: (data: string) => void) {
		this.subscribers.add(callback);
		return () => this.subscribers.delete(callback);
	}

	publish(message: string) {
		this.subscribers.forEach((callback) => callback(message));
	}
}

export const eventManager = new EventManager();
