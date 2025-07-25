
import Foundation

public enum CompStatus: Double {
    case nothing = 0
    case instDependencies = 2
    case instRepo = 15
    case copyingFiles = 20
    case patching = 45
    case compiling = 65
    case finishingUp = 90
    case finished = 100
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
    case checkingHomebrewInstallation
    case checkingIntelHomebrewInstallation
    case installingDeps
    case finishingUp
}

public enum TitlebarAppearence: Int {
    case normal = 0
    case unified = 1
}
