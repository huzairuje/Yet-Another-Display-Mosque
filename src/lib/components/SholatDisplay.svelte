<script lang="ts">
	import { fade } from 'svelte/transition';
</script>

<div
	class="fixed inset-0 z-[100] flex flex-col items-center justify-center bg-black text-white"
	transition:fade
>
	<div class="flex animate-pulse flex-col items-center">
		<h1 class="mb-4 text-7xl font-light tracking-[0.5em] uppercase opacity-50">Sedang Shalat</h1>
		<p class="text-2xl font-extralight tracking-widest italic opacity-30">
			Mohon nonaktifkan HP Anda
		</p>
	</div>
</div>
