//

public struct Patch: Hashable {
    var name = ""
    var repoCompatibility = [String()]
    var patchInstallationCommand = ""
    var buildFlags = ""
}

public var builtinPatches = [
    "highfps": Patch(name: "60 FPS", repoCompatibility: ["sm64ex"], patchInstallationCommand: "git apply ./enhancements/60fps_ex.patch --ignore-whitespace --reject", buildFlags: ""),
    "highfpsalo": Patch(name: "60 FPS", repoCompatibility: ["sm64ex_alo"], patchInstallationCommand: "", buildFlags: "HIGH_FPS_PC=1"),
    "debug": Patch(name: "Debug", repoCompatibility: ["sm64coopdx"], patchInstallationCommand: "", buildFlags: "DEBUG=1"),
    "betterCam": Patch(name: "Better Camera (Puppycam)", repoCompatibility: ["sm64ex", "sm64ex_alo", "render96ex"], patchInstallationCommand: "", buildFlags: "BETTERCAMERA=1"),
    "noDrawDist": Patch(name: "No Draw Distance", repoCompatibility: ["sm64ex", "sm64ex_alo", "render96ex"], patchInstallationCommand: "", buildFlags: "NODRAWDISTANCE=1"),
    "extData": Patch(name: "External Data", repoCompatibility: ["sm64ex", "sm64ex_alo", "render96ex"], patchInstallationCommand: "", buildFlags: "EXTERNAL_DATA=1"),
    "timeTrials": Patch(name: "Time Trials", repoCompatibility: ["sm64ex"], patchInstallationCommand: "wget https://sm64pc.info/downloads/patches/time_trials.2.4.hotfix.patch && git apply --reject --ignore-whitespace 'time_trials.2.4.hotfix.patch'", buildFlags: ""),
    "qolFixes": Patch(name: "Quality of Life Fixes", repoCompatibility: ["sm64ex_alo"], patchInstallationCommand: "", buildFlags: "QOL_FIXES=1"),
    "qolFeatures": Patch(name: "Quality of Life Features", repoCompatibility: ["sm64ex_alo"], patchInstallationCommand: "", buildFlags: "QOL_FEATURES=1"),
    "star_road": Patch(name: "Super Mario Star Road", repoCompatibility: ["sm64ex_alo"], patchInstallationCommand: "wget -O star_road_release.patch http://drive.google.com/uc\\?id\\=1kXskWESOTUJDoeCGVV9JMUkn0tLd_GXO && git apply --reject --ignore-whitespace star_road_release.patch", buildFlags: ""),
]

/*public enum Patches: String {
    case highfps = "60Fps"
    case debug = "Debug"
    case extMoveset = "Extended Moveset"
    case bettercam = "Better Camera"
    case drawdistance = "No Draw Distance"
    case extData = "External Data"
    case timeTrials = "Time Trials"
    case captainToadStars = "Captain Toad Stars"
    case qolFixes = "Quality of Life Fixes"
    case qolFeatures = "Quality of Life Features"
    case star_road = "Super Mario Star Road"
    case nothing = ""
}*/
