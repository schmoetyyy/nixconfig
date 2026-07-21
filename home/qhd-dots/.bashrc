alias ll="ls -a"
alias hyco="vim /home/schmoetyyy/nixconfig/home/qhd-dots/hypr/hyprland.lua"
alias nxrb="cd ~/nixconfig && git add . && sudo nixos-rebuild switch --flake /home/schmoetyyy/nixconfig --impure && cd -"
alias nxrbf="sudo nixos-rebuild switch --flake /home/schmoetyyy/nixconfig --impure"
alias nxco="sudo vim /home/schmoetyyy/nixconfig/configuration.nix"
alias snow="shutdown now"
alias rewayb="pkill waybar ; sleep 1 ; waybar & disown"
alias cr='cd ~/.local/share/waylandcrosshair && ./crosshair 0.99 & disown'
alias ki='pkill crosshair'
PS1='\[\033[0;36m\]\w #\[\e[0m\] '
fastfetch 
            
