export interface Scene {
	enter?: (previous: Scene, ...args: any[]) => void;
	leave?: (next: Scene, ...args: any[]) => void;
	pause?: (next: Scene, ...args: any[]) => void;
	resume?: (previous: Scene, ...args: any[]) => void;
	[index: string]: any;
}

export interface HookOptions {
	include?: string[];
	exclude?: string[];
}

export interface Manager {
	emit: (event: any, ...args: any[]) => void;
	enter: (next: Scene, ...args: any[]) => void;
	push: (next: Scene, ...args: any[]) => void;
	pop: (...args: any[]) => void;
	hook: (options?: HookOptions) => void;
}

export function newManager(): Manager;
