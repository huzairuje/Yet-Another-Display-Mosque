/**
 * Format angka ke Rupiah dengan titik (Contoh: 1.000 RP)
 */
export function formatRupiah(amount: number | string): string {
	const num = typeof amount === 'string' ? parseInt(amount.replace(/[^0-9]/g, '')) : amount;
	if (isNaN(num)) return '0 RP';
	return new Intl.NumberFormat('id-ID').format(num) + ' RP';
}

/**
 * Format angka ke format ringkas "K" (Contoh: 100K, 1.5JT)
 */
export function formatK(amount: number): string {
	if (amount >= 1000000) {
		return (amount / 1000000).toFixed(amount % 1000000 === 0 ? 0 : 1) + 'JT';
	}
	if (amount >= 1000) {
		return (amount / 1000).toFixed(amount % 1000 === 0 ? 0 : 1) + 'K';
	}
	return amount.toString();
}

/**
 * Bersihkan string dari karakter non-angka
 */
export function parseRaw(value: string): number {
	return parseInt(value.replace(/[^0-9]/g, '')) || 0;
}
