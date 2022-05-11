
11 # DataSHIELD disclosure settings
12 #

set.standard.disclosure.settings <- function() {
    options(datashield.privacyLevel = "5")
    options(default.nfilter.glm = "0.33")
    options(default.nfilter.kNN = "3")
    options(default.nfilter.string = "80")
    options(default.nfilter.subset = "3")
    options(default.nfilter.stringShort = "20")
    options(default.nfilter.tab = "3")
    options(default.nfilter.noise = "0.25")
    options(default.nfilter.levels = "0.33")
}
