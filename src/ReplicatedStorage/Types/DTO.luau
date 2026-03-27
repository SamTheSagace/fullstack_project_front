local DTO = {}

export type CreateSessionInput = {
	name: string,
	display_name: string,
	owner_roblox_user_id: number,
	owner_server_id: string,
}

export type JoinSessionInput = {
	roblox_user_id: number,
	display_name: string,
}

export type LeaveSessionInput = {
	roblox_user_id: number,
}

return DTO
