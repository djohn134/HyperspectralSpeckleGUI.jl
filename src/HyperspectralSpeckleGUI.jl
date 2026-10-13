module HyperspectralSpeckleGUI
    using QML
    using Dates
    using Colors
    using GLMakie
    using QMLMakie
    using HyperspectralSpeckle
    QML.setGraphicsApi(QML.OpenGL)

    export OpenGUI

    function OpenGUI()
        ## Observables & local variables
        defaultDatatype = Observable{String}("Float32")
        FTYPE = @lift(eval(Symbol($defaultDatatype)))
        
        targetArray = Observable{Matrix{Float64}}(randn(256, 256))
        windowColor = Observable{String}("")
        windowText = Observable{String}("")

        apertureDiameter = Observable{Float64}(3.6)
        obscurationFraction = Observable{Float64}(0.0)
        fieldOfView = Observable{Float64}(5.0)
        imageDatatype = Observable{String}("UInt16")
        DTYPE = @lift(($imageDatatype == "Default") ? $FTYPE : eval(Symbol($imageDatatype)))
        readNoise = Observable{Float64}(2.0)
        wellDepth = Observable{Float64}(100000.0)
        gain = @lift(($DTYPE <: AbstractFloat) ? 1.0 : $wellDepth / typemax($DTYPE))
        exposureTime = Observable{Float64}(5.0)
        quantumEfficiency = Observable{Union{Float64, AbstractVector{Float64}}}(0.8)
        wfsType = Observable{String}("Shack-Hartmann")
        microlensArrayLength = Observable{Int64}(6)
        transmissionFullAp = Observable{Union{Float64, AbstractVector{Float64}}}(0.5)
        transmissionWfs = Observable{Union{Float64, AbstractVector{Float64}}}(0.5)
        includeAdc = Observable{Bool}(true)
        refWavelength = Observable{Float64}(500.0)
        Dr0 = Observable{Float64}(20.0)
        zenithAngle = Observable{Float64}(0.0)
        atmosphericTransmission = Observable{Union{Float64, AbstractVector{Float64}}}(1.0)
        layerHeights = Observable{Vector{Float64}}([0.0, 7.0, 12.5])
        windSpeed = Observable{Vector{Float64}}([5.0, 7.5, 35.0])
        windDirection = Observable{Vector{Float64}}([45.0, 125.0, 135.0])
        randomSeed = Observable{Vector{Float64}}([713, 1212, 525118])
        zernikeIndex = Observable{Int64}(4)
        numWaves = Observable{Float64}(1.0)
        diversityPeriod = Observable{Float64}(200.0)
        referenceTime = Observable{Float64}(0.0)
        targetBrightness = Observable{Float64}(6.0)
        backgroundBrightness = Observable{Float64}(21.0)
        targetRange = Observable{Float64}(500.0)
        truthTargetImage = Observable{Matrix{Float64}}(zeros(Float64, 1, 1))
        includeNoise = Observable{Bool}(true)
        propagateLayers = Observable{Bool}(true)
        simulateAnisoplanatic = Observable{Bool}(true)
        patchSize = Observable{Int64}(64)
        numTimesteps = Observable{Int64}(10)
        lowerWavelength = Observable{Float64}(400.0)
        upperWavelength = Observable{Float64}(1000.0)
        nyquistWavelength = Observable{Float64}(400.0)
        numWavelengths = Observable{Int64}(5)
        imageSizeFullAp = Observable{Int64}(256)
        imageSizeWfs = Observable{Int64}(64)
        runId = Observable{String}(Dates.format(now(), "yyyymmdd-HHMMSS"))

        ## QMLMakie figures 
        targetFigure = Figure(figure_padding=5)
        targetAx = Axis(targetFigure[1, 1], aspect = AxisAspect(1.0))
        targetImage = heatmap!(targetAx, truthTargetImage, colormap = :grays)
        targetColorbar = Colorbar(targetFigure[1, 2], targetImage)
        hidedecorations!(targetAx)
        targetFigureObs = Observable(targetFigure)

        ## Observables sent to QML
        observables = QML.JuliaPropertyMap(
            "defaultDatatype" => defaultDatatype,
            "apertureDiameter" => apertureDiameter,
            "obscurationFraction" => obscurationFraction,
            "fieldOfView" => fieldOfView,
            "imageDatatype" => imageDatatype,
            "readNoise" => readNoise,
            "wellDepth" => wellDepth,
            "gain" => gain,
            "exposureTime" => exposureTime,
            "quantumEfficiency" => quantumEfficiency,
            "wfsType" => wfsType,
            "microlensArrayLength" => microlensArrayLength,
            "transmissionFullAp" => transmissionFullAp,
            "transmissionWfs" => transmissionWfs,
            "includeAdc" => includeAdc,
            "refWavelength" => refWavelength,
            "Dr0" => Dr0,
            "zenithAngle" => zenithAngle,
            "atmosphericTransmission" => atmosphericTransmission,
            "layerHeights" => layerHeights,
            "windSpeed" => windSpeed,
            "windDirection" => windDirection,
            "randomSeed" => randomSeed,
            "includeNoise" => includeNoise,
            "zernikeIndex" => zernikeIndex,
            "numWaves" => numWaves,
            "diversityPeriod" => diversityPeriod,
            "referenceTime" => referenceTime,
            "targetBrightness" => targetBrightness,
            "backgroundBrightness" => backgroundBrightness,
            "targetRange" => targetRange,
            "propagateLayers" => propagateLayers,
            "simulateAnisoplanatic" => simulateAnisoplanatic,
            "patchSize" => patchSize,
            "numTimesteps" => numTimesteps,
            "lowerWavelength" => lowerWavelength,
            "upperWavelength" => upperWavelength,
            "nyquistWavelength" => nyquistWavelength,
            "numWavelengths" => numWavelengths,
            "imageSizeFullAp" => imageSizeFullAp,
            "imageSizeWfs" => imageSizeWfs,
            "targetFigureObs" => targetFigureObs,
            "windowColor" => windowColor,
            "windowText" => windowText,
            "runId" => runId
        )

        on(windowColor) do color
            targetFigure.scene.backgroundcolor[] = parse(Colorant, color)
        end

        on(windowText) do color
            targetColorbar.ticklabelcolor = parse(Colorant, color)
            targetColorbar.tickcolor = parse(Colorant, color)
        end

        function loadTruthImage(pathToImage)
            truthTargetImage[] = readfits(pathToImage)
            xlims!(targetAx, [0, size(truthTargetImage[], 2)])
            ylims!(targetAx, [0, size(truthTargetImage[], 1)])
            notify(targetFigureObs)
        end

        ## Julia functions sent to QML
        @qmlfunction loadTruthImage

        loadqml(joinpath(dirname(@__FILE__), "MainGui.qml"), observables=observables)
        exec()
    end

end
