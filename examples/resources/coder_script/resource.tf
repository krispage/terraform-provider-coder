data "coder_workspace" "me" {}

resource "coder_agent" "dev" {
  os   = "linux"
  arch = "amd64"
  dir  = "/workspace"
}

resource "coder_script" "dotfiles" {
  agent_id     = coder_agent.dev.id
  display_name = "Dotfiles"
  icon         = "/icon/dotfiles.svg"
  run_on_start = true
  script = templatefile("~/get_dotfiles.sh", {
    DOTFILES_URI : var.dotfiles_uri,
    DOTFILES_USER : var.dotfiles_user
  })
}

resource "coder_script" "code-server" {
  agent_id           = coder_agent.dev.id
  display_name       = "code-server"
  icon               = "/icon/code.svg"
  run_on_start       = true
  start_blocks_login = true
  script = templatefile("./install-code-server.sh", {
    LOG_PATH : "/tmp/code-server.log"
  })
}

resource "coder_script" "nightly_update" {
  agent_id     = coder_agent.dev.id
  display_name = "Nightly update"
  icon         = "/icon/database.svg"
  cron         = "0 0 22 * * *" # Run at 22:00 (10 PM) every day
  script       = <<EOF
    #!/bin/sh
    echo "Running nightly update"
    sudo apt-get update
  EOF
}

resource "coder_script" "every_5_minutes" {
  agent_id     = coder_agent.dev.id
  display_name = "Health check"
  icon         = "/icon/heart.svg"
  cron         = "0 */5 * * * *" # Run every 5 minutes
  script       = <<EOF
    #!/bin/sh
    echo "Health check at $(date)"
  EOF
}

resource "coder_script" "shutdown" {
  agent_id     = coder_agent.dev.id
  display_name = "Stop daemon server"
  run_on_stop  = true
  icon         = "/icons/memory.svg"
  script       = <<EOF
    #!/bin/sh 
    kill $(lsof -i :3002 -t) >/tmp/pid.log 2>&1 &
  EOF
}