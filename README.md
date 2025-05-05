# Random scripts for practical or fun use

## `check-tailscale.sh`
I have been playing Factorio with a friend recently, and he's been having difficulty downloading the map and catching up to the server. We think it has something to do with Crapcast not playing nicely with UDP traffic. I recently started using [Tailscale](https://tailscale.com) and decided to try using it for our connection as I had seen some people online suggest using a VPN as a possible solution. It turns out this worked really well.

However, I don't want to leave tailscale running on my computer because it opens up my computer to a potential security threat. I wrote this script to automatically shut down tailscale on my computer if a) tailscale is running, b) factorio is NOT running, and c) the user (me) is idle.

### Usage
This was only tested on a basic Linux Mint installation without major modifications. Your mileage may vary.

1. Download the script `check-tailscale.sh`
2. Download the service file `check-tailscale.service`
3. Replace the `ExecStart` with the path to the script file
4. (optional) Update the `TICK` and `IDLE_TIME` values
    - `TICK` - How often the script checks for idleness (default: 5 minutes)
    - `IDLE_TIME` - How long until the user is deemed to be idle (default: 30 minutes)
5. Place the service file in the systemd location (my location is `/etc/systemd/system/check-tailscale.service`)
6. Set up the systemd service:
    ```bash
    sudo systemctl daemon-reload && \
      sudo systemctl enable check-tailscale && \
      sudo systemctl start check-tailscale
    ```
    - `sudo systemctl daemon-reload` makes systemd aware of the new service
    - `sudo systemctl enable check-tailscale` makes systemd start the service when the system boots
    - `sudo systemctl start check-tailscale` starts the service now
