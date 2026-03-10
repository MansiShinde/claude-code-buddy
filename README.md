# Claude Code Buddy

An animated companion that sits at the top of your terminal while you use Claude CLI. The cute robot shows what Claude is doing in real-time — reading files, editing code, searching, thinking, and more.

```
    ▄ ▄       ▄ ▄
      ▄▄▄▄▄▄▄        ⟳ editing code
      █ ██   ██ █
      █         █
      █   ▄▄▄   █
      ▀▀▀█ ▓▓▓ █▀▀▀    ← laptop!
         ▔▔▔▔▔
         ▀▀▀▀▀▀▀
───────────────────────────────────────────
   Claude CLI runs here, full width below
```

Animations include:
- **Idle:** blinking, looking around, sleeping (zzz), singing, winking
- **Coding:** typing on laptop with blue screen
- **Building:** wearing a yellow hard hat
- **Searching:** holding a magnifying glass
- **Reading:** wearing glasses
- **Thinking:** sparkle eyes with magic effects
- **Coffee break:** holding a steaming mug

## Features

- Animated robot buddy in a small top tmux pane
- Real-time activity detection — shows what tool Claude is currently using
- Different animations for idle vs working states
- Labels: reading files, editing code, running commands, searching code, thinking, etc.
- Works with every new Claude CLI session
- Zero impact on Claude CLI performance

## Requirements

- [Claude CLI](https://docs.anthropic.com/en/docs/claude-code) installed and in PATH
- [tmux](https://github.com/tmux/tmux) — terminal multiplexer
- [jq](https://jqlang.github.io/jq/) — JSON processor

### Install dependencies (macOS)

```bash
brew install tmux jq
```

### Install dependencies (Linux)

```bash
sudo apt install tmux jq
```

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-buddy.git
cd claude-code-buddy
chmod +x install.sh
./install.sh
```

Then reload your shell:

```bash
source ~/.zshrc  # or ~/.bashrc
```

## Usage

```bash
# Start Claude CLI with the buddy
claude-buddy

# Pass any Claude CLI arguments
claude-buddy -p "explain this code"
claude-buddy --model sonnet

# Skip permissions mode (alias: shizuka)
shizuka
```

## How It Works

1. `claude-with-buddy.sh` launches a tmux session with two panes:
   - **Top pane** (5 lines): The animated buddy robot
   - **Bottom pane** (rest of terminal): Claude CLI at full width

2. `claude-buddy-animation.sh` monitors Claude's transcript files in `~/.claude/projects/` to detect:
   - Whether Claude is idle or working
   - Which tool Claude is currently using (Read, Edit, Bash, Grep, etc.)

3. The buddy animates accordingly — idle animations when waiting, working animations with activity labels when Claude is active.

## Customization

### Change animation speed

Edit `claude-buddy-animation.sh` and modify:

```bash
FRAME_DELAY=0.5       # seconds between frames
STATE_CHECK_EVERY=2   # check Claude's state every N frames
```

### Change buddy pane height

Edit `claude-with-buddy.sh` and modify:

```bash
BUDDY_HEIGHT=6  # 5 lines for mascot + 1 border
```

## Manual Installation (without install.sh)

```bash
# Copy scripts
mkdir -p ~/.claude/scripts
cp claude-buddy-animation.sh ~/.claude/scripts/
cp claude-with-buddy.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/claude-buddy-animation.sh
chmod +x ~/.claude/scripts/claude-with-buddy.sh

# Add aliases to your shell rc file
echo "alias claude-buddy='bash ~/.claude/scripts/claude-with-buddy.sh'" >> ~/.zshrc
echo "alias shizuka='bash ~/.claude/scripts/claude-with-buddy.sh --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
```

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
source ~/.zshrc
```

## File Structure

```
claude-code-buddy/
├── README.md                    # This file
├── install.sh                   # One-command installer
├── uninstall.sh                 # Clean uninstaller
├── claude-with-buddy.sh         # Launcher (tmux setup)
└── claude-buddy-animation.sh    # Animation engine
```

## License

MIT
