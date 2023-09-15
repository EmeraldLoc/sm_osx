
import Foundation

public enum Repo: String {
    case none = ""
    case sm64ex = "https://github.com/sm64pc/sm64ex.git"
    case sm64ex_master = "https://github.com/EmeraldLoc/sm64ex.git --branch master"
    case sm64ex_alo = "https://github.com/EmeraldLoc/sm64ex-alo.git"
    case moonshine = "https://github.com/EmeraldLoc/sm64-moonshine"
    case moon64 = "https://github.com/EmeraldLoc/Moon64"
    case render96ex = "https://github.com/EmeraldLoc/sm64ex.git --branch alpha"
    case sm64ex_coop = "https://github.com/djoslin0/sm64ex-coop.git"
    case sm64ex_coop_dev = "https://github.com/sm64ex-coop-dev/sm64ex-coop.git"
}

public enum Patches: String {
    case omm = "https://github.com/PeachyPeachSM64/sm64ex-omm.git"
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
    case instRepo = 5
    case copyingFiles = 15
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
    case compilingAppearence
    case checkingHomebrewInstallation
    case checkingIntelHomebrewInstallation
    case installingDeps
    case finishingUp
}

public enum CompilationAppearence: Int {
    case compact = 0
    case full = 1
}

public enum TitlebarAppearence: Int {
    case normal = 0
    case unified = 1
}

public enum TransparencyAppearence:  String, CaseIterable {
    case normal
    case more
}
