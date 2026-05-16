# pi-gen stage (stub)

This folder is a placeholder for a future `pi-gen` stage that bakes dpos
directly into a flashable `.img` file, so you (or anyone) can write the
SD card and boot straight into the themed desktop.

It is **not wired yet.** Validate the script path first, then promote it.

## Plan when we get to it

`pi-gen` (the upstream Raspberry Pi OS image-builder) ships with stages
`stage0`..`stage5`. The pattern is:

1. Clone https://github.com/RPi-Distro/pi-gen
2. Drop a new stage directory `stage-dpos/` next to the existing ones
3. Layout:
   ```
   stage-dpos/
   ├── prerun.sh           # symlinks rootfs from previous stage
   ├── 00-install-dpos/
   │   ├── 00-packages     # all packages from scripts/10..70
   │   ├── 00-run-chroot.sh
   │   └── files/          # tarball of this dpos/ directory
   └── EXPORT_IMAGE        # presence enables image export
   ```
4. `00-run-chroot.sh` runs inside the chroot and is essentially
   `./install.sh --yes --skip 00,99` (preflight and Pi-tuning are
   pointless inside the build chroot, they get handled at first boot).
5. `STAGE_LIST="stage0 stage1 stage2 stage-dpos"` for a minimal image
   (no desktop carrying over from stage4/5 — we install our own).
6. Build host: a real x86_64 Linux box with `qemu-user-static` and
   `binfmt-support`. Building on the Pi itself works but takes hours.

## Why not now

The script-on-Lite path:
- Boots in minutes instead of hours per iteration
- Doesn't require an x86 build host
- Lets the operator tweak before the next reflash
- Surfaces hardware-specific failures immediately (we get to fail loud)

Once `install.sh` has run cleanly on a Pi 4B end-to-end, baking the image
is a few hundred lines of pi-gen glue. Until then this stub stays empty.

## See also

- pi-gen upstream: https://github.com/RPi-Distro/pi-gen
- pi-gen examples: https://github.com/RPi-Distro/pi-gen/tree/master/stage2
