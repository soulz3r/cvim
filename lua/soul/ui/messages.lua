local M={}
local function setup_native_messages()
  local ui2=require("vim._core.ui2")
  ui2.enable({msg={targets="cmd"}})
  local messages=require("vim._core.ui2.messages")
  local original_msg_show=messages.msg_show
  local message_generation=0
  messages.msg_show=function(...)
    original_msg_show(...)
    message_generation=message_generation+1
    local generation=message_generation
    vim.defer_fn(function()
      if generation==message_generation then messages.msg_clear() end
    end,5000)
  end
end

function M.open_output(title,output)
  local lines=vim.split(output or "","\\n",{plain=true})
  if #lines==0 or (#lines==1 and lines[1]=="") then lines={"No output."} end
  local available_width=math.max(1,vim.o.columns-4)
  local available_height=math.max(1,vim.o.lines-vim.o.cmdheight-4)
  local width=math.min(available_width,math.max(1,math.min(120,math.floor(vim.o.columns*0.85))))
  local height=math.min(available_height,math.max(1,math.min(30,math.floor((vim.o.lines-vim.o.cmdheight)*0.75))))
  local row=math.floor((vim.o.lines-vim.o.cmdheight-height)/2)
  local col=math.floor((vim.o.columns-width)/2)
  local buf=vim.api.nvim_create_buf(false,true)
  vim.api.nvim_buf_set_lines(buf,0,-1,false,lines)
  vim.bo[buf].buftype="nofile"
  vim.bo[buf].bufhidden="wipe"
  vim.bo[buf].modifiable=false
  vim.bo[buf].swapfile=false
  vim.bo[buf].filetype="vim"
  local win=vim.api.nvim_open_win(buf,true,{
    relative="editor",row=row,col=col,width=width,height=height,
    style="minimal",border="rounded",title=" "..title.." ",title_pos="center",
  })
  vim.wo[win].wrap=false
  vim.wo[win].cursorline=false
  vim.keymap.set("n","q","<cmd>close<cr>",{buffer=buf,silent=true})
  vim.keymap.set("n","<Esc>","<cmd>close<cr>",{buffer=buf,silent=true})
end

local function open_messages()
  M.open_output("Messages",vim.api.nvim_exec2("messages",{output=true}).output)
end

local float_commands={
  map=true,nmap=true,vmap=true,xmap=true,smap=true,omap=true,
  imap=true,lmap=true,cmap=true,tmap=true,
  scriptnames=true,registers=true,highlight=true,marks=true,
  jumps=true,changes=true,digraphs=true,
}

local function command_output(command_line)
  local command=command_line:match("^%s*(%S+)%s*$")
  if not command then return nil end
  command=command:lower()
  if not float_commands[command] then return nil end
  local ok,result=pcall(vim.api.nvim_exec2,command,{output=true})
  if not ok then return nil end
  return command,result.output
end

function M.setup()
  setup_native_messages()
  vim.api.nvim_create_user_command("Messages",open_messages,{desc="Show message history in a centered, titled window"})
  vim.keymap.set("c","<CR>",function()
    if vim.fn.getcmdtype()~=":" then return "<CR>" end
    local command_line=vim.fn.getcmdline()
    if vim.trim(command_line):lower()=="messages" then return "<C-u>Messages<CR>" end
    local command,output=command_output(command_line)
    if command then
      vim.schedule(function() M.open_output(command,output) end)
      return "<C-c>"
    end
    return "<CR>"
  end,{expr=true,noremap=true,desc="Open inspectable command output in a floating window"})
end
return M
