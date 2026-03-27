local CommonTypes = {}

export type SessionMember = {
	id: number?,
	roblox_user_id: number?,
	display_name: string?,
	role: string?,
	status: string?,
	joined_at: string?,
	left_at: string?,
	last_seen_at: string?,
}

export type Session = {
	id: number?,
	code: string?,
	name: string?,
	status: string?,
	owner_roblox_user_id: number?,
	created_at: string?,
	updated_at: string?,
	session_members: { SessionMember }?,
}

export type ListSessionsResponse = {
	sessions: { Session }?,
}

return CommonTypes