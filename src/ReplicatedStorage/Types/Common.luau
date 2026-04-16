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
	current_item_id: number?,
	items: { Item }?,
}

export type Item = {
	created_by_roblox_user_id: number,
    title: string,
    description: string,
    position: number,
    status: string,
	cost: number | nil,
}

export type ListSessionsResponse = {
	sessions: { Session }?,
}

export type SessionSnapshotMember = {
	userId: number,
	name: string,
	participate: boolean,
	isReady: boolean,
	isSeated: boolean,
}

export type SessionSnapshot = {
	code: string,
	name: string,
	phase: string,
	hostUserId: number,
	members: { SessionSnapshotMember },
	seatMap: { [number]: string },
	playerCount: number,
	seatedCount: number,
	readyCount: number,
}

return CommonTypes
