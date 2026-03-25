<script lang="ts">
	import { prayerService } from '$lib/prayer.svelte';
	import { settings } from '$lib/settings.svelte';
	import { formatRupiah, formatK } from '$lib/utils/format';
	import PrayerCard from '$lib/components/PrayerCard.svelte';
	import RunningText from '$lib/components/RunningText.svelte';
	import FocusTimer from '$lib/components/FocusTimer.svelte';
	import SholatDisplay from '$lib/components/SholatDisplay.svelte';
	import KhutbahDisplay from '$lib/components/KhutbahDisplay.svelte';
	import DebugOverlay from '$lib/components/DebugOverlay.svelte';
	import {
		Wallet,
		Calendar,
		Clock,
		Info,
		BellRing,
		TrendingUp,
		TrendingDown,
		Sparkles,
		Quote,
		Mic2
	} from 'lucide-svelte';
	import { fade, slide } from 'svelte/transition';
	import { onMount } from 'svelte';

	// Jam pake titik biar sama kayak screenshot
	function formatTime(date: Date) {
		const h = date.getHours().toString().padStart(2, '0');
		const m = date.getMinutes().toString().padStart(2, '0');
		const s = date.getSeconds().toString().padStart(2, '0');
		return `${h}.${m}.${s}`;
	}

	let showDebug = $state(false);

	const nextPrayer = $derived.by(() => {
		const pt = prayerService.prayerTimes;
		const now = prayerService.currentTime;
		if (now < pt.fajr) return { name: 'Subuh', time: pt.fajr };
		if (now < pt.sunrise) return { name: 'Syuruq', time: pt.sunrise };
		if (now < pt.dhuhr) return { name: 'Dzuhur', time: pt.dhuhr };
		if (now < pt.asr) return { name: 'Ashar', time: pt.asr };
		if (now < pt.maghrib) return { name: 'Maghrib', time: pt.maghrib };
		if (now < pt.isha) return { name: 'Isya', time: pt.isha };
		return { name: 'Subuh', time: pt.fajr };
	});

	const latestIn = $derived(settings.value.transactions.filter((t) => t.type === 'in').slice(0, 3));
	const latestOut = $derived(settings.value.transactions.filter((t) => t.type === 'out').slice(0, 3));

	// BACKGROUND SLIDESHOW
	let bgIndex = $state(0);
	const currentBg = $derived(
		settings.value.backgrounds.length > 0 ? settings.value.backgrounds[bgIndex] : null
	);

	// INFO SLIDESHOW (MOTD/HADITS)
	let infoIndex = $state(0);
	const activeInfos = $derived(settings.value.infos.filter(i => i.active));
	const currentInfo = $derived(activeInfos.length > 0 ? activeInfos[infoIndex % activeInfos.length] : null);

	onMount(() => {
		settings.load();

		const handleKeyDown = (e: KeyboardEvent) => {
			const isDebugMode = new URLSearchParams(window.location.search).get('vibe') === 'debug';
			if (isDebugMode && e.key.toLowerCase() === 'd') showDebug = !showDebug;
			if (e.key === 'Escape') showDebug = false;
		};
		window.addEventListener('keydown', handleKeyDown);

		let eventSource: EventSource;
		function initSSE() {
			if (eventSource) eventSource.close();
			eventSource = new EventSource('/api/events');
			eventSource.onmessage = (e) => { if (e.data === 'update') settings.load(); };
			eventSource.onerror = () => { setTimeout(initSSE, 5000); };
		}
		initSSE();

		// Timer Background
		const bgTimer = setInterval(() => {
			if (settings.value.backgrounds.length > 1)
				bgIndex = (bgIndex + 1) % settings.value.backgrounds.length;
		}, (settings.value.bgSlideshowDuration || 60) * 1000);

		// Timer Info Slideshow
		const infoTimer = setInterval(() => {
			if (activeInfos.length > 1) infoIndex = (infoIndex + 1) % activeInfos.length;
		}, (settings.value.infoSlideshowDuration || 15) * 1000);

		return () => {
			window.removeEventListener('keydown', handleKeyDown);
			if (eventSource) eventSource.close();
			clearInterval(bgTimer);
			clearInterval(infoTimer);
		};
	});

	const bigInfoFontSize = $derived.by(() => {
		const len = settings.value.bigInfo.length;
		if (len < 20) return 'text-[10rem]';
		if (len < 50) return 'text-[7rem]';
		if (len < 100) return 'text-[5rem]';
		return 'text-[3.5rem]';
	});

	const themeConfig = $derived.by(() => {
		switch (settings.value.theme) {
			case 'modern':
				return { 
					bg: 'from-slate-900 via-slate-950 to-black', 
					accent: 'text-slate-400', 
					clock: 'text-white', 
					pill: 'border-slate-400/30 bg-slate-600/40', 
					jumat: { border: 'border-slate-500/30', bg: 'bg-slate-600/20', text: 'text-slate-400' },
					info: { bg: 'bg-slate-500/20', text: 'text-slate-400' }
				};
			case 'classic':
				return { 
					bg: 'from-emerald-900 via-teal-950 to-black', 
					accent: 'text-emerald-400', 
					clock: 'text-emerald-50', 
					pill: 'border-emerald-400/30 bg-emerald-600/40', 
					jumat: { border: 'border-emerald-500/30', bg: 'bg-emerald-600/20', text: 'text-emerald-400' },
					info: { bg: 'bg-emerald-500/20', text: 'text-emerald-400' }
				};
			case 'ocean':
				return { 
					bg: 'from-blue-900 via-cyan-950 to-black', 
					accent: 'text-cyan-400', 
					clock: 'text-white', 
					pill: 'border-cyan-400/30 bg-cyan-600/40', 
					jumat: { border: 'border-cyan-500/30', bg: 'bg-cyan-600/20', text: 'text-cyan-400' },
					info: { bg: 'bg-cyan-500/20', text: 'text-cyan-400' }
				};
			case 'sunset':
				return { 
					bg: 'from-rose-900 via-orange-950 to-black', 
					accent: 'text-orange-400', 
					clock: 'text-white', 
					pill: 'border-orange-400/30 bg-orange-600/40', 
					jumat: { border: 'border-orange-500/30', bg: 'bg-orange-600/20', text: 'text-orange-400' },
					info: { bg: 'bg-orange-500/20', text: 'text-orange-400' }
				};
			default: // vibe
				return { 
					bg: 'from-blue-900 via-purple-950 to-black', 
					accent: prayerService.vibe.accent, 
					clock: 'text-white', 
					pill: 'border-blue-400/30 bg-blue-600/40', 
					jumat: { border: 'border-purple-500/30', bg: 'bg-purple-600/20', text: 'text-purple-400' },
					info: { bg: 'bg-blue-500/20', text: 'text-blue-400' }
				};
		}
	});
</script>

<div
	class="relative h-screen max-h-screen w-screen overflow-hidden bg-black font-sans text-white p-6"
>
	<!-- Background Layer -->
	<div class="absolute inset-0 z-0 bg-gradient-to-br {themeConfig.bg}"></div>

	<!-- Main Bento Dashboard (The 4-Row Grid) -->
	<div class="relative z-10 grid h-full w-full grid-rows-[35vh_auto_1fr_auto] gap-6 overflow-hidden">
		
		<!-- ROW 1: HEADER (Slideshow & Stats) -->
		<div class="grid grid-cols-12 gap-6 h-[35vh]">
			<!-- LEFT: Slideshow -->
			<div
				class="relative col-span-8 overflow-hidden rounded-[2rem] border border-white/10 bg-white/5 shadow-2xl backdrop-blur-3xl"
			>
				{#if currentBg}
					{#key currentBg}
						<img
							src={currentBg}
							alt=""
							class="absolute inset-0 h-full w-full object-cover transition-all duration-[2000ms]"
							transition:fade={{ duration: 2000 }}
						/>
					{/key}
				{:else}
					<div class="flex h-full w-full items-center justify-center opacity-20">
						<Sparkles class="h-16 w-16 mr-4" />
						<span class="text-4xl font-black uppercase tracking-[0.4em]">Vibe Mosque</span>
					</div>
				{/if}
			</div>

			<!-- RIGHT: Clock & Kas -->
			<div class="col-span-4 flex flex-col gap-6 h-full">
				<!-- Clock -->
				<div class="relative flex flex-[1.5] flex-col justify-center items-center rounded-[2rem] border border-white/10 bg-white/5 p-4 shadow-xl backdrop-blur-3xl overflow-hidden">
					<h2 class="mb-1 text-center text-lg font-light italic leading-tight text-white/80">{prayerService.gregorianDate}</h2>
					<h3 class="text-center text-2xl font-black {themeConfig.accent}">{prayerService.hijriDate}</h3>
					<div class="mt-2 flex flex-col items-center text-center">
						<div class="text-6xl font-black leading-none tabular-nums tracking-tight {themeConfig.clock} drop-shadow-lg">
							{formatTime(prayerService.currentTime).split('.').slice(0, 2).join(':')}
							<span class="text-2xl opacity-50">.{formatTime(prayerService.currentTime).split('.')[2]}</span>
						</div>
						<div class="mt-3 flex items-center gap-2 rounded-full border px-4 py-1.5 shadow-xl backdrop-blur-xl {themeConfig.pill}">
							<BellRing class="h-3.5 w-3.5 animate-pulse text-white" />
							<span class="text-xs font-bold tracking-wide text-white">
								{nextPrayer.name}: {nextPrayer.time.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }).replace(':', '.')}
							</span>
						</div>
					</div>
				</div>
				<!-- Kas -->
				<div class="relative flex flex-1 flex-col justify-between overflow-hidden rounded-[2rem] border border-white/10 bg-white/5 p-4 shadow-xl backdrop-blur-3xl min-h-0">
					<div class="flex justify-between items-start">
						<div class="flex items-center gap-2">
							<div class="rounded-xl border border-emerald-500/20 bg-emerald-500/20 p-1.5 backdrop-blur-md">
								<Wallet class="h-4 w-4 text-emerald-400" />
							</div>
							<span class="text-[9px] font-black uppercase tracking-[0.2em] opacity-80">Kas</span>
						</div>
						<span class="text-xl font-black leading-none tabular-nums text-emerald-400">{formatRupiah(settings.value.cash)}</span>
					</div>
					<div class="mt-2 grid grid-cols-2 gap-3">
						<div class="space-y-1">
							{#each latestIn as tx}
								<div class="flex items-center justify-between rounded-lg border border-white/5 bg-white/5 px-2 py-0.5 text-[8px] font-bold">
									<span class="truncate uppercase opacity-80">{tx.desc}</span>
									{#if !settings.value.hideTransactionAmount}<span class="text-emerald-400 font-black">{formatK(tx.amount)}</span>{/if}
								</div>
							{/each}
						</div>
						<div class="space-y-1">
							{#each latestOut as tx}
								<div class="flex items-center justify-between rounded-lg border border-white/5 bg-white/5 px-2 py-0.5 text-[8px] font-bold">
									<span class="truncate uppercase opacity-80">{tx.desc}</span>
									{#if !settings.value.hideTransactionAmount}<span class="text-rose-400 font-black">-{formatK(tx.amount)}</span>{/if}
								</div>
							{/each}
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- ROW 2: MIDDLE (Quote & Khathib) -->
		<div class="flex flex-col gap-4">
			<!-- Quote -->
			<div class="relative flex h-24 items-center gap-6 rounded-[2rem] border border-white/10 bg-white/5 px-10 shadow-2xl backdrop-blur-3xl overflow-hidden">
				{#if currentInfo}
					{#key currentInfo.id}
						<div class="flex items-center gap-8 w-full" in:fade={{delay: 500}} out:fade>
							<div class="flex flex-col items-center gap-2">
								<div class="rounded-2xl p-2.5 {themeConfig.info.bg}"><Quote class="h-5 w-5 {themeConfig.info.text}" /></div>
								<span class="text-[8px] font-black uppercase tracking-widest whitespace-nowrap {themeConfig.info.text}/60">{currentInfo.header}</span>
							</div>
							<div class="min-w-0 flex-1">
								<p class="text-xl font-bold leading-tight tracking-wide text-white/90 italic line-clamp-2">"{currentInfo.content}"</p>
								<p class="mt-1 text-[9px] font-black tracking-widest text-slate-500 uppercase">— {currentInfo.footer || 'Informasi'}</p>
							</div>
						</div>
					{/key}
				{:else}
					<div class="flex items-center justify-center w-full opacity-20"><span class="text-lg font-bold uppercase tracking-[0.4em]">Masjid Vibe</span></div>
				{/if}
			</div>
			<!-- Khathib Banner (Hanya muncul hari Jumat) -->
			{#if prayerService.isFriday}
				<div class="flex items-center justify-between rounded-[1.5rem] border px-10 py-2.5 shadow-2xl backdrop-blur-3xl {themeConfig.jumat.border} {themeConfig.jumat.bg}" transition:slide>
					<div class="flex items-center gap-4">
						<Mic2 class="h-5 w-5 {themeConfig.jumat.text}" />
						<div class="flex flex-col">
							<span class="text-[7px] font-black uppercase tracking-[0.4em] {themeConfig.jumat.text}/80 leading-none mb-1">Khathib Jum'at</span>
							<span class="text-xl font-black tracking-tight text-white uppercase leading-none">{settings.value.fridayKhatib}</span>
						</div>
					</div>
					<div class="flex items-center gap-3 opacity-40">
						<Sparkles class="h-4 w-4 {themeConfig.jumat.text}" /><span class="text-xs font-bold italic tracking-widest text-white/80">Jum'at Berkah</span>
					</div>
				</div>
			{/if}
		</div>

		<!-- ROW 3: BOTTOM CONTENT (Prayer Cards) - Fills the rest of space -->
		<div class="flex gap-6 items-stretch min-h-0 h-full">
			<div class="flex-1 min-h-0 h-full"><PrayerCard name="Subuh" time={prayerService.prayerTimes.fajr} isActive={nextPrayer.name === 'Subuh'} /></div>
			<div class="flex-1 min-h-0 h-full"><PrayerCard name="Syuruq" time={prayerService.prayerTimes.sunrise} isActive={nextPrayer.name === 'Syuruq'} /></div>
			<div class="flex-1 min-h-0 h-full"><PrayerCard name={prayerService.isFriday ? "Jum'at" : "Dzuhur"} time={prayerService.prayerTimes.dhuhr} isActive={nextPrayer.name === 'Dzuhur'} /></div>
			<div class="flex-1 min-h-0 h-full"><PrayerCard name="Ashar" time={prayerService.prayerTimes.asr} isActive={nextPrayer.name === 'Ashar'} /></div>
			<div class="flex-1 min-h-0 h-full"><PrayerCard name="Maghrib" time={prayerService.prayerTimes.maghrib} isActive={nextPrayer.name === 'Maghrib'} /></div>
			<div class="flex-1 min-h-0 h-full"><PrayerCard name="Isya" time={prayerService.prayerTimes.isha} isActive={nextPrayer.name === 'Isya'} /></div>
		</div>

		<!-- ROW 4: RUNNING TEXT (Now a full citizen of the grid) -->
		<RunningText />
	</div>

	<!-- Informasi Utama (Big Info) -->
	{#if settings.value.bigInfo}
		<div class="fixed inset-0 z-[200] flex items-center justify-center p-12 md:p-24" transition:fade>
			<div class="absolute inset-0 bg-black/85 backdrop-blur-3xl"></div>
			<div class="relative flex min-h-[50vh] w-full max-w-7xl items-center justify-center rounded-[4rem] border border-white/10 bg-white/5 p-16 shadow-2xl backdrop-blur-[80px] md:p-24">
				<p class="{bigInfoFontSize} break-words whitespace-pre-wrap text-center font-black leading-[1.1] text-white overflow-hidden">{settings.value.bigInfo}</p>
			</div>
		</div>
	{/if}

	{#if prayerService.mode === 'preadzan' || prayerService.mode === 'iqomah'}<FocusTimer />
	{:else if prayerService.mode === 'sholat'}<SholatDisplay />
	{:else if prayerService.mode === 'khutbah'}<KhutbahDisplay />
	{/if}

	{#if showDebug}<DebugOverlay onClose={() => (showDebug = false)} />{/if}
</div>

<style>
	:global(body) { margin: 0; background: #000; cursor: none; user-select: none; }
</style>
