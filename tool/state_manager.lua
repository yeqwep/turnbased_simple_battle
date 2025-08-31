-- state_manager.lua
-- 汎用的な状態管理システム（Defold向けに最適化）

local M = {}

-- 履歴の上限を超えた場合の履歴クリーニング
local function cleanup_history(state_history, max_history_size)
	if #state_history > max_history_size then
		table.remove(state_history, 1) -- 最古のエントリを削除
		-- print(string.format("State history cleaned up. Kept %d entries.", #state_history))
	end
end

-- 状態遷移を即座に処理
local function transition(manager_data, state_name, data, back_history)
	local states = manager_data.states
	local context = manager_data.context
	local state_history = manager_data.state_history
	local max_history_size = manager_data.max_history_size
	
	-- 移動する時履歴に追加（履歴を戻る時は記録しない）
	if manager_data.current_state then
		if not back_history then
			table.insert(state_history, manager_data.current_state.name)
			cleanup_history(state_history, max_history_size)
		else
			-- 戻る場合は履歴から削除
			table.remove(state_history, #state_history)
		end
	end
	
	-- 現在の状態を終了
	if manager_data.current_state and manager_data.current_state.exit then
		manager_data.current_state.exit(context, data)
	end
	
	-- 新しい状態に遷移
	if states[state_name] then
		manager_data.current_state = states[state_name]
		
		if states[state_name].enter then
			states[state_name].enter(context, data)
		end
		
		-- print(string.format("State transition: %s", state_name))
	else
		print(string.format("ERROR: State '%s' not found", state_name))
	end
end

-- 状態管理用のクロージャファクトリー
M.create_state_manager = function(options)
	-- オプションのデフォルト値
	options = options or {}
	local max_history_size = options.max_history_size or 1
	
	-- 管理データをテーブルにまとめる
	local manager_data = {
		current_state = {},
		states = {},
		context = {},
		state_history = {},
		max_history_size = max_history_size,
	}
	
	-- 外部インターフェース
	return {
		-- 複数の状態を一度に追加
		add_states = function(state_definitions)
			for name, state_def in pairs(state_definitions) do
				state_def.name = name
				manager_data.states[name] = state_def
			end
		end,
		
		-- 状態遷移（外部から直接呼び出し可能）
		transition = function(state_name, data)
			transition(manager_data, state_name, data, false)
		end,
		
		-- 現在の状態名を取得
		get_current_state_name = function()
			return manager_data.current_state and manager_data.current_state.name or nil
		end,
		
		-- 状態履歴を取得
		get_state_history = function()
			return manager_data.state_history
		end,
		
		-- 履歴のクリア
		clear_history = function()
			manager_data.state_history = {}
			print("State history cleared")
		end,
		
		-- 履歴設定の取得
		get_history_settings = function()
			return {
				max_size = manager_data.max_history_size,
				current_size = #manager_data.state_history
			}
		end,
		
		-- メッセージハンドリング
		on_message = function(message_id, message, sender)
			if manager_data.current_state and manager_data.current_state.on_message then
				manager_data.current_state.on_message(manager_data.context, message_id, message, sender)
			end
		end,
		
		-- 入力ハンドリング
		on_input = function(action_id, action)
			if manager_data.current_state and manager_data.current_state.on_input then
				manager_data.current_state.on_input(manager_data.context, action_id, action)
			end
		end,
		
		-- 更新処理
		update = function(dt)
			if manager_data.current_state and manager_data.current_state.update then
				manager_data.current_state.update(manager_data.context, dt)
			end
		end,
		
		-- コンテキストの設定
		set_context = function(new_context)
			manager_data.context = new_context
		end,
		
		-- コンテキストの取得
		get_context = function()
			return manager_data.context
		end,
		
		-- コンテキストの値を設定
		set_context_value = function(key, value)
			manager_data.context[key] = value
		end,
		
		-- コンテキストの値を取得
		get_context_value = function(key)
			return manager_data.context[key]
		end,
		
		-- 状態の存在確認
		has_state = function(state_name)
			return manager_data.states[state_name] ~= nil
		end,
		
		-- 登録されている状態の一覧を取得
		get_state_list = function()
			local state_list = {}
			for name, _ in pairs(manager_data.states) do
				table.insert(state_list, name)
			end
			return state_list
		end,
		
		-- 状態管理システムのリセット
		reset = function()
			if manager_data.current_state and manager_data.current_state.exit then
				manager_data.current_state.exit(manager_data.context, {reason = "reset"})
			end
			manager_data.current_state = nil
			manager_data.state_history = {}
			print("State manager reset")
		end,
		
		-- 状態管理システムの破棄
		destroy = function()
			if manager_data.current_state and manager_data.current_state.exit then
				manager_data.current_state.exit(manager_data.context, {reason = "destroy"})
			end
			manager_data.current_state = nil
			manager_data.states = {}
			manager_data.context = {}
			manager_data.state_history = {}
			print("State manager destroyed")
		end,

		-- 前の状態に戻る
		go_back = function(data)
			if #manager_data.state_history > 0 then
				local last_state = manager_data.state_history[#manager_data.state_history]
				transition(manager_data, last_state, data, true)
			else
				print("No previous state to go back to")
			end
		end,
		
		-- 内部データへのアクセス（デバッグ用）
		get_manager_data = function()
			return manager_data
		end
	}
end

return M