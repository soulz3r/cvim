local M = {
  enabled = false,
}

local function get_ui2()
  if vim.fn.has("nvim-0.12") ~= 1 then
    return nil, "Neovim 0.12 or newer is required"
  end

  local ok, ui2 = pcall(require, "vim._core.ui2")
  if not ok or type(ui2) ~= "table" or type(ui2.enable) ~= "function" then
    return nil, "Neovim UI2 is unavailable"
  end

  return ui2
end

local function restore_message_handler()
  if not M.messages or not M.original_messages_msg_show then
    return
  end

  M.message_generation = (M.message_generation or 0) + 1
  M.messages.msg_show = M.original_messages_msg_show
  M.messages = nil
  M.original_messages_msg_show = nil
end

function M.available()
  return get_ui2() ~= nil
end

function M.is_enabled()
  return M.enabled
end

local message_timeouts = {
  emsg = 6000,
  lua_error = 6000,
  echoerr = 6000,
  rpc_error = 6000,
  shell_err = 4000,
  wmsg = 4000,
  echo = 2000,
  echomsg = 2000,
  quickfix = 2000,
  search_count = 2000,
  return_prompt = false,
  confirm = false,
  input = false,
  list_cmd = false,
}

function M.setup()
  if M.enabled then
    return true
  end

  local ui2, err = get_ui2()
  if not ui2 then
    return false, err
  end

  local ok, enable_error = pcall(ui2.enable, {
    enable = true,
    msg = { targets = "cmd" },
  })
  if not ok then
    return false, tostring(enable_error)
  end

  M.ui2 = ui2

  local messages_ok, messages = pcall(require, "vim._core.ui2.messages")
  if messages_ok and type(messages.msg_show) == "function" then
    local original_msg_show = messages.msg_show
    M.message_generation = (M.message_generation or 0) + 1

    messages.msg_show = function(kind, ...)
      M.message_generation = M.message_generation + 1
      local current_generation = M.message_generation

      original_msg_show(kind, ...)

      local timeout = message_timeouts[kind]
      if timeout == nil then
        timeout = 2000
      end

      if timeout == false then
        return
      end

      vim.defer_fn(function()
        if current_generation == M.message_generation and type(messages.msg_clear) == "function" then
          messages.msg_clear()
        end
      end, timeout)
    end

    M.messages = messages
    M.original_messages_msg_show = original_msg_show
  end

  M.enabled = true
  return true
end

function M.install_notifications()
  if not M.enabled or type(M.ui2.msg) ~= "table" then
    return false, "Neovim UI2 message handlers are unavailable"
  end

  if M.notifications_installed then
    return true
  end

  local original_msg_show = M.ui2.msg.msg_show
  if type(original_msg_show) ~= "function" then
    return false, "Neovim UI2 msg_show handler is unavailable"
  end

  M.ui2.msg.msg_show = function(kind, ...)
    return original_msg_show(kind, ...)
  end

  M.original_ui2_msg_show = original_msg_show
  M.notifications_installed = true
  return true
end

function M.restore_notifications()
  if not M.notifications_installed or not M.ui2 or type(M.ui2.msg) ~= "table" then
    return
  end

  M.ui2.msg.msg_show = M.original_ui2_msg_show
  M.original_ui2_msg_show = nil
  M.notifications_installed = false
end

function M.restore()
  if not M.enabled then
    return true
  end

  M.restore_notifications()
  restore_message_handler()

  local ok, err = pcall(M.ui2.enable, { enable = false })
  if not ok then
    return false, "Could not disable Neovim UI2: " .. tostring(err)
  end

  M.enabled = false
  M.ui2 = nil
  return true
end

return M
