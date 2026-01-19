#! /usr/bin/env zsh

#### ZPROFILE
####
#### Made by Raul Morales Delgado


## PLATFORM DETECTION
# Set platform variable for conditional logic throughout config
case "$OSTYPE" in
    darwin*)  DOTFILES_PLATFORM="macos" ;;
    linux*)   DOTFILES_PLATFORM="linux" ;;
    *)        DOTFILES_PLATFORM="unknown" ;;
esac
export DOTFILES_PLATFORM


## SSH AGENT
# Skip if running in a container (agent is forwarded from host)
# Note: We can't just check SSH_AUTH_SOCK because macOS sets it automatically
if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && ! -f "/.dockerenv" ]]; then
    
    # Starting the ssh-agent:
    printf '%s' "[.zprofile][ssh-agent] "
    
    # Creating function to run ssh-agent in sub-shell (notice "()" instead of "{}"):
    run_ssh_agent () (

        # Creating function to add keys:
        add_key_to_ssh_agent () {
            # Create local placeholder for associative array:
            local tmp="$1"
            # Check if specific private key has already been added (notice "--" in grep command, this is because its expanding a variable; won't work without):
            if { ssh-add -l|grep -i -- "${(P)${tmp}[1]}" &> /dev/null ; } ; then
                    printf '%s' "${(P)${tmp}[1]} private key already added. "
                else
                    # Add key if not added yet:
                    ssh-add "${(P)${tmp}[2]}" &>/dev/null && 
                    printf '%s' "${(P)${tmp}[1]} private key successfully added. " || 
                    printf '%s' "${RED} Failed to add private key for ${(P)${tmp}[1]}${NORMAL}. "
            fi
        }

        # Running ssh-add, error code tells status of ssh-agent:
        ssh-add -l &>/dev/null
        
        # Locally storing exit status:
        local ssh_agent_status=$?

        # Check if $?<=2 (2: not initialized; 1: initialized with no keys; 0: initialized with keys):
        if [[ "ssh_agent_status" -le 2 ]]; then
            # Check if $?=2, this means agent not initialized: 
            if [[ "ssh_agent_status" -eq 2 ]]; then
                eval "$(ssh-agent)" >/dev/null &&
                printf '%s' "Agent initialized. " ||
                { printf '%s\n' "${RED}Failed to initialize agent.${NORMAL}"; exit 1 ; }
            fi
            # Adding the Github private key to ssh-agent:
            for i in "$@"; do
                add_key_to_ssh_agent "$i"
            done
            printf '%s\n' ""
        fi
    )
    
    # Setting keys to be used:
    github=('Github' "$HOME/.ssh/github_ecdsa")
    
    # Run:
    run_ssh_agent "github"
    
    unset -f run_ssh_agent
    unset github
else
    printf '%s\n' "[.zprofile][ssh-agent] Container detected, skipping initialization (agent forwarded from host)."
fi
## END OF SSH AGENT


## HOMEBREW (macOS only)

if [[ "$DOTFILES_PLATFORM" == "macos" ]]; then
    # Load Homebrew's env vars and binaries to PATH and Zsh completions to FPATH
    # Docs: https://docs.brew.sh/Homebrew-on-MacOS
    brew_init () {
        printf '%s' "[.zprofile][brew] "
        # Detect Homebrew path (Apple Silicon vs Intel)
        local brew_path=""
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            brew_path="/opt/homebrew/bin/brew"  # Apple Silicon
        elif [[ -x "/usr/local/bin/brew" ]]; then
            brew_path="/usr/local/bin/brew"     # Intel
        fi

        if [[ -n "$brew_path" ]]; then
            eval "$($brew_path shellenv)" &&
            printf '%s\n' "Successfully initialized." ||
            printf '%s\n' "${RED}Failed to initialize.${NORMAL}"
        else
            printf '%s\n' "${RED}Homebrew not found.${NORMAL}"
        fi
    }

    brew_init
    unset -f brew_init
fi

## END OF HOMEBREW


#### END OF ZPROFILE
