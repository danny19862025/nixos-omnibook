
{ config, pkgs, ... }:
#close lid not suspend laptop
{
services.logind.settings.Login = {
  HandleLidSwitch = "ignore";
  HandleLidSwitchExternalPower = "ignore";
  HandleLidSwitchDocked = "ignore";
};
  imports =
    [ ./hardware-configuration.nix ];

  hardware.uinput.enable = true;
       # Allow unfree packages
         nixpkgs.config.allowUnfree = true;
nix.settings.experimental-features = [ "nix-command" "flakes" ];
	fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fantasque-sans-mono
  ];
	programs.zsh.enable = true;
	programs.starship.enable = true;
        services.openssh.enable = true;
	programs.fish.enable = true;
  #claude in vs code 
  programs.nix-ld.enable = true;

boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_1; 

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
networking.extraHosts = "10.8.0.1 wordpress.local";
  networking.hostName = "omnibook"; # Define your hostname.
   networking.wireless.enable = true;   #Enables wireless support via wpa_supplicant.
	networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Australia/Sydney";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."danny" = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "danny";
 # Add "video" inside your existing group list:
  extraGroups = [ "networkmanager" "wheel" "video" "docker" "uinput" ];
#    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird

    ];
  };

  # Install firefox.
  programs.firefox.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget


  environment.systemPackages = with pkgs; [
  	 vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
 	 wget
	 git
	 ghostty
	 bat
	 tmux
	 neovim
	 flatpak
	fastfetch
	hyfetch
	brave
        alacritty
        google-chrome
        vscode
		zsh
		zsh-autosuggestions
		zsh-syntax-highlighting
		starship
			hyprland
			waybar
			kitty
			quickshell	
				wofi
				nautilus
				grim
				slurp
				wl-clipboard
				hyprpaper
				pywal
	wireguard-tools
 	 openresolv
	btop
	htop	
	rclone
            kubectl
            k9s
	networkmanagerapplet
	overskride
	ydotool
	swaynotificationcenter
	hyprsunset
	wlogout
	pkgs.claude-code
    tree-sitter
    ripgrep
    fd
    gcc
    gnumake
    unzip
    nodejs
    python3
obsidian
         virt-manager
          qemu
     (python3.withPackages (ps: [ ps.tkinter ]))
      ];


networking.firewall.allowedUDPPorts = [ 51820 ];

systemd.user.services."rclone-sync" = {
  wantedBy = [ "default.target" ];
  after = [ "network-online.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.rclone}/bin/rclone copy /home/danny/Documents NixosBackup:NixosBackup --verbose";
  };
};
systemd.user.timers."rclone-sync" = {
  description = "Run Rclone Sync every 5 minutes";
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "*:0/5";
    Persistent = true;

  };
};
systemd.user.services.gdrive-personal-sync = {
    description = "NixOS BackUP";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # Changed 'gdrive_personal' to 'NixosBackup' to match your rclone setup!
      # We are saving it into a folder also named 'NixosBackup' on that drive.
      ExecStart = "${pkgs.rclone}/bin/rclone copy /home/danny/Documents NixosBackup:NixosBackup --verbose";
    };
  };

  systemd.user.timers.gdrive-personal-sync = {
    description = "Trigger Private Google Drive Sync every hour";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";       
      OnUnitActiveSec = "1h";  
    };
  };
  system.stateVersion = "26.05"; # Did you read the comment?

programs.hyprland.enable = true;

# Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Optimise storage by hard-linking duplicate files
  nix.settings.auto-optimise-store = true;

nix.nixPath = [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos" ];

services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://192.168.0.10:6443";
    tokenFile = "/etc/rancher/k3s/token";
  };

networking.wg-quick.interfaces.wg0 = {
    address = [ "10.8.0.13/24" ];
    privateKeyFile = "/etc/wireguard/omnibook-private.key";
    peers = [{
      publicKey = "V9aaaT5VANoXG5p+BP3WT6rnBEyqtxi6d/IvUF1e838=";
      endpoint = "49.187.133.208:51820";
      allowedIPs = [ "10.8.0.0/24" ];
      persistentKeepalive = 25;
    }];
  };	


  # Enable libvirtd VM 
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };




}

