module HyperspectralSpeckleGUI
    using QML
    using QMLMakie

    export OpenGUI

    function OpenGUI()
        loadqml(joinpath(dirname(@__FILE__), "MainGui.qml"))
        exec()
    end

end
