# eso-linux-launcher
Launcher for Elder Scrolls Online on Linux with a addon updater and a TTC price table updater.

Starts ESO through steam and closes the ESO launcher once ESO starts (this is reported to improve performance), keeps addons updated with https://www.esoui.com, keeps TTC price table up to date https://us.tamrieltradecentre.com/

By default this is setup to work with the steam version of ESO, check ell.sh for the comments up top if you want to use it without steam.

---

### Usage

Make ell.sh executable `chmod u+x ell.sh`

Run ell.sh `./ell.sh`

---

### Addons

#### Updating / adding Addons:

If you want it to update your addons, put the links to the addons in addons.txt,
one per line. For example:

`https://www.esoui.com/downloads/info1536-ActionDurationReminder.html`  
`https://www.esoui.com/downloads/info57-HarvestMap.html`


Then run `ESO_ADDONS_PATH=/PATH/TO/ESO/AddOns UPDATE_ADDONS=1 ell.sh` changing `/PATH/TO/ESO/Addons`, for example `~/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/My Documents/Elder Scrolls Online/live/AddOns`


#### Deleting Addons:

If you want to delete an addon, put the word `del` with a space in front of the line in addons.txt ; example:

`del https://www.esoui.com/downloads/info1536-ActionDurationReminder.html ActionDurationReminder 3.3.6c ActionDurationReminder`

---

### TTC

If you want it to keep the TTC price table up to date run ell.sh like so:

`ESO_ADDONS_PATH=/PATH/TO/ESO/AddOns UPDATE_TTC=1 ell.sh`

You can upate addons and TTC also:

`ESO_ADDONS_PATH=/PATH/TO/ESO/AddOns UPDATE_TTC=1 UPDATE_ADDONS=1 ell.sh`


