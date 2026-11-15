# First current-version tablet build

2026-11-14. User authorized building/installing the current version for tablet review. Source0.12.1/code13,all10games. No gameplay sourcechanges in this step.

## Build verification

- APK build/android/little-wonder-world-debug.apk:32,942,842bytes,31.42MiB. This is compressed APK size,not installedstorage ormemory.
- SHA256:3A7AC82C5460D2FAE1A4FF2D38A509DB2C57B19AC397D29A296A8E71BA24CB8B.
- Package org.littlewonderworld.app,versionName0.12.1,versionCode13,minSDK24,targetSDK36,ARM64only.
- Godot export/import completed;signaturev2/v3 and16KB-aware ZIP alignment passed;no uses-permission entries;requiredcatalogs/locales/licenses present;development files excluded.
-236WAV import descriptors (228speech+8instrument),all referencedGodot imported resources present. Godot exports imported audio rather than raw WAV payloads.

## Installation and initial launch

One authorized USB Redmi model25099RP13G/flute;Android16,arm64-v8a reverified. Targetpackage absent beforeinstallation. Targeted adb install -r returnedSuccess;no uninstall/cleardata. Installedpackage confirmed0.12.1/code13.

Resolved launcher com.godot.game.GodotAppLauncher;am start -W Status:ok,ColdlaunchTotalTime747ms/WaitTime767ms. This activitylaunchmeasurement is not measured gameinputlatency orfullcontentloadtime. Actualactivity com.godot.game.GodotApp. Godot setup/mainloop started;process remainedrunning atcheck. Only that process'slog was captured;no global logclearing.

No SCRIPT ERROR,Godot ERROR/resourcefailure orAndroidRuntime FATAL EXCEPTION found in capturedstartup. Vendor warnings includeSELinuxsysfsdenial andFrameInsert missingfile;their deepercause/impact was not established. Appremainedrunning;do not call theentiresystemlog warning-free.

Evidence:.local/logs/android-{import,export,build-current}.log,apk-{signature,alignment,badging}.log,tablet-first-launch.log. Appleftlaunched foruserreview. No tablet UIsettings changed,newdownloads,Git actions or personalgallerydeletion.

## User review next

Check AnimalsEnglishspeech,drag/dropgames,continuousDrawing/save/reopen,Coloringregions,andXylophone simultaneousfingers. Thenbackground/resume,audiosettings andofflineplay. Physicaltouch,FPS/RSS,installedstorage,airplanemode andsubjectivevoice remainpending. PCnormalgallery isnotcopied totablet;eachplatform keepsprivate localartwork. No fullAndroidacceptance claimed. Known desktopproductdifferences inRELEASE_REVIEW.md remain.


## Android 0.14.0 installed - 2026-11-14

User connected tablet and authorized update. Redmi25099RP13G/flute re-enumerated as authorized. Previous installed0.12.1/code13 updated to0.14.0/code15 with install --no-incremental -r (Success). Initial default incremental/streamed attempt failed with an empty diagnostic; explicit non-incremental retry succeeded. No uninstall,clear-data or device settings changes. Update semantics preserve existing private app data; individual artwork contents were not inspected.

APK35,151,396bytes (33.52MiB),SHA256BBC5BA639D7080C7EBCE3934C488230269E46C10047B03775DDEC5F79FAC8844. Signature,alignment,package/ABI/min24/target36,permissions andrequired resource checks passed.358speech+8instrument import targets andballoon-pop resource packaged. Installed version confirmed by package manager. Launcher GodotAppLauncher opened GodotApp,Statusok,cold start606ms/Wait641ms (activity-launch timing,not input latency). App left open for user review. Startup log .local/logs/tablet-014-launch.log; no full physical-gameplay/performance acceptance implied. Current update includes virtual scrolling,full Ukrainian Tetiana speech,idle finger hints,icon tools andsix-balloon completion.

## Android 0.16.0 installed — 2026-11-14

User explicitly authorized tablet installation. Authorized Redmi25099RP13G/flute reverified. Updated0.14.0/code15 to0.16.0/code17 using targeted adb install --no-incremental -r: Success. No uninstall or clear-data; update preserves private app data, individual saved artwork was not inspected.

APK36,769,808bytes; SHA256 AD02095A031DF4E16790812D839953A3FA9392D3CABC7D0DDAEDF80228CB41AB. Export,signature,ZIP alignment,package/ARM64,permissions and required World catalog packaging checks passed. Package manager confirms0.16.0/code17. Launcher Status:ok, cold activity launch736ms/Wait742ms (not gameplay latency). Process32671 remained running. Startup log: .local/logs/tablet-016-launch.log. App left open; physical gameplay, pronunciation and performance acceptance remain user review. Includes0.15feedback pack and0.16bilingual World/history features.

## Android 0.17.0 installed — 2026-11-14

User requested installation and APK/folder links. Authorized Redmi25099RP13G/flute verified. Updated0.16.0/code17 to0.17.0/code19 using targeted install --no-incremental -r:Success. No uninstall/clear-data; normal data-preserving update semantics, individual saved artwork not inspected.

APK build/android/little-wonder-world-debug.apk:38,615,448bytes (36.83MiB), SHA256468EEC213838B0EF28DBA1C284716A4B7653C0BB0E56E4607D9DFA91855EBD58. Export/signature/alignment/package/ARM64/permissions/required-assets checks passed. Installed package manager confirms0.17.0/code19. Launcher Status:ok; cold activity launch653ms/Wait660ms, not gameplay latency. Process9872 remained running. Startup log .local/logs/tablet-017-launch.log. App left open for user gameplay/listening review. Includes slow upward balloons, locale-bound alphabet with illustrated cards, random pictured word assembly and detailed interactive body. No full physical gameplay/performance acceptance claimed.

## Android 0.18.0 installed — 2026-11-14

User authorized update and requested PC APK link. Authorized Redmi25099RP13G/flute verified. Updated0.17.0/code19 to0.18.0/code20 using targeted install --no-incremental -r:Success. No uninstall/clear-data; standard data-preserving update, individual saved artwork not inspected.

APK build/android/little-wonder-world-debug.apk:40,955,145bytes (39.06MiB),SHA25685E45B0A6F6D4800179708A98B8D0D5B63A23A58200AACA8FA9FB3E40BE37F9A. Export/signature/alignment/package/ARM64/permissions/required-assets checks passed. Both character import descriptors/imported texture targets and boy/girl geometry explicitly checked in APK. Installed package manager confirms0.18.0/code20. Launcher Status:ok,cold activity launch927ms/Wait966ms,not gameplay latency. Process17106 remained running;startup log.local/logs/tablet-018-launch.log. App left open for user review. Includes two illustrated people,eleven companions,twelve faster balloons and revised59letter recordings. Physical gameplay and subjective pronunciation remain user acceptance.


## Android0.25.0 installed - 2026-11-15

User explicitly requested tablet installation. Authorized USB Redmi25099RP13G/flute,Android16,previous0.18.0/code20 reverified. Exported0.25.0/code29,packageorg.littlewonderworld.app,ARM64. APKsignature,16KiB ZIPalignment,metadata,noAndroidpermissions andrequiredasset checks passed. All710speech import descriptors and imported audio targets verified insideAPK;developmentTetianaHighmodel excluded.

APK build/android/little-wonder-world-debug.apk:42,565,904bytes(40.59MiB),SHA256DE2FDAC42BB2167BD1E27654F899CD44325628D0D9EC10405923E72689DCC40A. Targetedadb install --no-incremental -r returnedSuccess;no uninstall,clear-data ordevice settings changes. Standarddata-preservingupdate;individualprivateartwork/settingscontentsnotinspected. Installedversionconfirmed0.25.0/code29. LaunchGodotAppLauncher→GodotApp Statusok,COLD,Total828ms/Wait848ms(activitylaunchtiming,notgameinputlatency). PID20376remainedrunning. Appleftopenforuserreview.

Startup .local/logs/tablet-025-launch.log: noSCRIPTERROR,ParseErrororAndroidRuntimeFATALfound. VendorAudioTrackreportedmissing/odm/etc/audio/audio_lowpower_app_list.xml;appremainedrunningwithaudio trackactivity. Thisdoesnotestablishallwarningsharmless/fullgameplayacceptance. No global logclearorpersonaldatainspection. Buildlog.local/logs/android-025-build.log. IncludesallPCincrements0.19–0.25:scroll/palette/layout,4livingstories,letter/digitrepetitioninseparatecategories,new369UKrecordings,Backtogallery,andoptionalEN→UKwordcaptionstoggle(defaultoff). Physicaltouch/performance/subjectivepronunciationremainuserreview.
