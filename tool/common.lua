local M = {}
-- -----------------------------------------------
-- Table Copy
-- -----------------------------------------------
function M.deepcopy(o, seen)
	seen = seen or {}
	if o == nil then
		return nil
	end
	if seen[o] then
		return seen[o]
	end

	local no = {}
	seen[o] = no
	setmetatable(no, M.deepcopy(getmetatable(o), seen))

	for k, v in next, o, nil do
		k = (type(k) == "table") and M.deepcopy(k, seen) or k
		v = (type(v) == "table") and M.deepcopy(v, seen) or v
		no[k] = v
	end
	return no
end

return M
