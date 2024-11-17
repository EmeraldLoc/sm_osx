
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
    "render96ex": Repo(name: "render96ex", customEndFileName: "", cloneURL: "https://github.com/Render96/Render96ex.git", branch: "", buildFlags: "", useOsxBuildFlag: true, x86_64: false),
    "sm64coopdx": Repo(name: "sm64coopdx", customEndFileName: "sm64coopdx", cloneURL: "https://github.com/coop-deluxe/sm64coopdx.git", branch: "", buildFlags: "USE_APP=0 COLOR=0", useOsxBuildFlag: true, x86_64: false)
]
