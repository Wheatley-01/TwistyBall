export type Module = {
	Init: (any) -> any,
	[string]: (...any) -> any,
}

return {}