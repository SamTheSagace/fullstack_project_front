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

export type CreateUpdateVoteInput = {
	item_id: number,
	roblox_user_id: number,
	value: string,
}

export type CreateItemInput = {
	title: string,
	description: string,
	session_id: number,
	status: string,
	created_by_roblox_user_id: number,
}

export type DeleteItemInput = {
	id: string,
	created_by_roblox_user_id: number,
}

return DTO
