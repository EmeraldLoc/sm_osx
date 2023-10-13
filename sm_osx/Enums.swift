
import Foundation

public enum Repo: String {
    case none = ""
    case sm64ex = "https://github.com/sm64pc/sm64ex.git"
    case sm64ex_alo = "https://github.com/AloUltraExt/sm64ex-alo.git"
    case moonshine = "https://github.com/EmeraldLoc/sm64-moonshine"
    case render96ex = "https://github.com/EmeraldLoc/Render96ex"
    case sm64ex_coop = "https://github.com/djoslin0/sm64ex-coop.git"
    case sm64ex_coop_dev = "https://github.com/sm64ex-coop-dev/sm64ex-coop.git -b dev"
    case custom = "custom"
}

public enum Patches: String {
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
}

public enum CompStatus: Double {
    case patching = 45
    case instDependencies = 2
    case instRepo = 15
    case copyingFiles = 20
    case compiling = 65
    case finishingUp = 90
    case finished = 100
    case nothing = 0
}

public enum Speed: String {
    case slow = ""
    case normal = "-j2"
    case fast = "-j3"
    case veryFast = "-j6"
    case fastest = "-j"
}

public enum FirstLaunchStatus {
    case none
    case starting
    case launcherView
    case titleBarAppearence
    case transparencyAppearence
    case checkingHomebrewInstallation
    case checkingIntelHomebrewInstallation
    case installingDeps
    case finishingUp
}

public enum TitlebarAppearence: Int {
    case normal = 0
    case unified = 1
}

public enum TransparencyAppearence:  String, CaseIterable {
    case normal
    case more
}
