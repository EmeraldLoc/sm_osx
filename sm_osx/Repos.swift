
import Foundation

public struct Repo: Hashable {
    var name = ""
    var customEndFileName = ""
    var cloneURL = ""
    var branch = ""
    var buildFlags = ""
    var useOsxBuildFlag = true
    var x86_64 = false
}

public var builtinRepos = [
    "sm64ex": Repo(name: "sm64ex", customEndFileName: "", cloneURL: "https://github.com/sm64pc/sm64ex.git", branch: "", buildFlags: "", useOsxBuildFlag: true, x86_64: false),
    "sm64ex_alo": Repo(name: "sm64ex_alo", customEndFileName: "", cloneURL: "https://github.com/AloUltraExt/sm64ex-alo.git", branch: "", buildFlags: "COLOR=0", useOsxBuildFlag: true, x86_64: false),
    "render96ex": Repo(name: "render96ex", customEndFileName: "", cloneURL: "https://github.com/EmeraldLoc/Render96ex.git", branch: "tester_rt64alpha", buildFlags: "", useOsxBuildFlag: true, x86_64: false),
]
