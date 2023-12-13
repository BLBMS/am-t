# For all android devices
adb shell settings put global sem_enhanced_cpu_responsiveness 1 #(More responsive CPU Default=0)
adb shell settings put global system_capabilities 100 #(Allows 100% resources usage Default=99)
adb shell settings put global adaptive_battery_management_enable 0 #(Disable adaptive battery)
adb shell settings put global adaptive_power_saving_setting 0 #(Disable adaptive power saving)
adb shell settings put global zram_enable 0 #(Disable RAM Plus)
adb shell settings put global ram_expand_size 0 #(Set the RAM Plus size to 0)
adb shell settings put global protect_battery 1 #(Protect battery only charges until 85% Default=0)
adb shell settings put global safe_wifi 1 #(Wi-Fi prefers stability over performance Default=0)
adb shell settings put global wifi_sleep_policy 2 #(Wi-Fi will always stay on Default=2)
adb shell settings put global stay_on_while_plugged_in 7 #(Screen stays on while plugged in to anything Default=0)
adb shell dumpsys deviceidle whitelist +tech.ula #(Add Userland app to battery optimization whitelist)
# Samsung Devices Only
adb uninstall --user 0 com.samsung.android.game.gametools #(Uninstall Game tools)
adb uninstall --user 0 com.samsung.android.game.gamehome #(Uninstall Game Space)
adb uninstall --user 0 com.samsung.android.game.gos #(Uninstall GOS known Samsung issue)
adb uninstall --user 0 com.sec.android.smartfpsadjuster #(Uninstall Fps Adjuster)

# Do not use these unless you've removed the battery and have active cooling!
adb shell settings put secure allow_more_heat_value 80 #(Caution Heat! increases heat threshold Default=0)
adb shell settings put global enhanced_processing 2 #(Caution Heat! better performance greater heat Default=0)
adb shell settings put global restricted_device_performance 0,0 #(Caution Heat! better performance greater heat Default>adb shell settings put global sem_low_heat_mode 0 #(Caution Heat! Disable throttling)
# Extras
# Disable Animations
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
# Favor CPU Performance over Power Savings
adb shell sudo sh -c "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
# Increase Background Process Limit
adb shell settings put global background_limit 4
# Always reboot when done
adb reboot #(Reboot device Mandatory!)
