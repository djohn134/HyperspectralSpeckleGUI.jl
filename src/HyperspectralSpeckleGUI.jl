module HyperspectralSpeckleGUI
    using QML
    using Dates
    using Colors
    using GLMakie
    using QMLMakie
    using Statistics
    using ColorSchemes
    using HyperspectralSpeckle
    QML.setGraphicsApi(QML.OpenGL)

    export OpenGUI

    function OpenGUI()
        ## Observables & local variables
        defaultDatatype = Observable{String}("Float32")
        FTYPE = @lift(eval(Symbol($defaultDatatype)))

        # GUI Style Parameters
        windowColor = Observable{String}("")
        windowText = Observable{String}("")
        windowDarkColor = Observable{String}("")

        # Model Parameters
        apertureDiameter = Observable{Float64}(3.6)
        obscurationFraction = Observable{Float64}(0.0)
        fieldOfView = Observable{Float64}(5.0)
        imageDatatype = Observable{String}("UInt16")
        DTYPE = @lift(($imageDatatype == "Default") ? $FTYPE : eval(Symbol($imageDatatype)))
        readNoise = Observable{Float64}(2.0)
        wellDepth = Observable{Float64}(30000)
        gain = @lift(($DTYPE <: AbstractFloat) ? 1.0 : Float64($wellDepth) / Float64(typemax($DTYPE)))
        exposureTime = Observable{Float64}(5.0e-3)
        quantumEfficiencyWavelength = Observable{AbstractVector{Float64}}([])
        quantumEfficiency = Observable{AbstractVector{Float64}}([0.8])
        wfsType = Observable{String}("Shack-Hartmann")
        microlensArrayLength = Observable{Int64}(6)
        numSubaps = Observable{Int64}(1)
        wavelengthFullAp = Observable{AbstractVector{Float64}}([])
        responseFullAp = Observable{AbstractVector{Float64}}([0.5])
        wavelengthWfs = Observable{AbstractVector{Float64}}([])
        responseWfs = Observable{AbstractVector{Float64}}([0.5])
        includeAdc = Observable{Bool}(true)
        refWavelength = Observable{Float64}(500.0e-9)
        Dr0 = Observable{Float64}(20.0)
        zenithAngle = Observable{Float64}(0.0)
        wavelengthTransmission = Observable{AbstractVector{Float64}}([])
        atmosphericTransmission = Observable{AbstractVector{Float64}}([1.0])
        layerHeights = Observable{Vector{Float64}}([0.0, 7000.0, 12500.0])
        windSpeed = Observable{Vector{Float64}}([5.0, 7.5, 35.0])
        windDirection = Observable{Vector{Float64}}([45.0, 125.0, 135.0])
        randomSeed = Observable{Vector{Float64}}([713, 1212, 525118])
        numLayers = Observable{Int64}(1)
        zernikeIndex = Observable{Int64}(4)
        numWaves = Observable{Float64}(1.0)
        diversityPeriod = Observable{Float64}(200.0e-3)
        referenceTime = Observable{Float64}(0.0)
        targetBrightness = Observable{Float64}(6.0)
        backgroundBrightness = Observable{Float64}(21.0)
        targetRange = Observable{Float64}(500.0e3)
        truthTarget = Observable{Array{Float64, 3}}(zeros(Float64, 1, 1, 1))
        truthTargetWavelengths = Observable{AbstractVector{Float64}}([1.0])
        includeNoise = Observable{Bool}(true)
        propagateLayers = Observable{Bool}(true)
        simulateAnisoplanatic = Observable{Bool}(true)
        patchSize = Observable{Int64}(64)
        numTimesteps = Observable{Int64}(10)
        lowerWavelength = Observable{Float64}(400.0e-9)
        upperWavelength = Observable{Float64}(1000.0e-9)
        nyquistWavelength = Observable{Float64}(400.0e-9)
        wavelength = Observable{Vector{Float64}}([])
        numWavelengths = Observable{Int64}(5)
        numWavelengthsSet = Observable{Int64}(1)
        numWavelengthsTarget = Observable{Int64}(1)
        spacingWavelength = @lift(($upperWavelength - $lowerWavelength)/($numWavelengths - 1))
        spectralResolution = @lift(0.5*($upperWavelength + $lowerWavelength) / $spacingWavelength)
        imageSizeFullAp = Observable{Int64}(256)
        imageSizeWfs = Observable{Int64}(64)
        saveDirectory = Observable{String}(pwd())
        runId = Observable{String}(Dates.format(now(), "yyyymmdd-HHMMSS"))
        
        enableFullAp = Observable{Bool}(true)
        enableWfs = Observable{Bool}(true)
        enableDiversity = Observable{Bool}(false)

        # GUI Slider Parameters
        currentTargetWavelength = Observable{Int64}(1)
        currentImageTimestep = Observable{Int64}(1)
        currentImageSubap = Observable{Int64}(1)
        currentImageWavelength = Observable{Int64}(1)
        currentAtmosphereLayer = Observable{Int64}(1)
        currentAtmosphereWavelength = Observable{Int64}(1)
        currentPupilWavelength = Observable{Int64}(1)

        ## QMLMakie figures
        cmocean_schemes = filter(p -> p.second.category == "cmocean", colorschemes)
        availableColormaps = Observable{Vector{String}}(sort(string.(collect(keys(cmocean_schemes)))))

        currentTargetColormap = Observable{String}("grays")
        imageRotation = Observable{Float64}(0.0)
        truthTargetImage = @lift(dropdims(mean($truthTarget, dims=3), dims=3))
        targetFigure = Figure(figure_padding=10)
        targetAx = Axis(targetFigure[1, 1], aspect = AxisAspect(1.0))
        targetImage = heatmap!(targetAx, truthTargetImage, colormap = Symbol(currentTargetColormap[]))
        targetColorbar = Colorbar(targetFigure[1, 2], targetImage)
        hidedecorations!(targetAx)
        targetFigureObs = Observable(targetFigure)

        currentImagesColormap = Observable{String}("grays")
        currentImage = Observable{Matrix{Float64}}(zeros(Float64, 1, 1))
        imagesFigure = Figure(figure_padding=10)
        imagesAx = Axis(imagesFigure[1, 1], aspect = AxisAspect(1.0))
        imagesImage = heatmap!(imagesAx, currentImage, colormap = Symbol(currentImagesColormap[]))
        imagesColorbar = Colorbar(imagesFigure[1, 2], imagesImage)
        hidedecorations!(imagesAx)
        imagesFigureObs = Observable(imagesFigure)

        currentAtmosphereColormap = Observable{String}("haline")
        currentAtmosphereImage = Observable{Matrix{Float64}}(zeros(Float64, 1, 1))
        atmosphereFigure = Figure(figure_padding=10)
        atmosphereAx = Axis(atmosphereFigure[1, 1], aspect = AxisAspect(1.0))
        atmosphereImage = heatmap!(atmosphereAx, currentAtmosphereImage, colormap = Symbol(currentAtmosphereColormap[]))
        atmosphereColorbar = Colorbar(atmosphereFigure[1, 2], atmosphereImage)
        hidedecorations!(atmosphereAx)
        atmosphereFigureObs = Observable(atmosphereFigure)

        currentPupilColormap = Observable{String}("grays")
        currentPupilImage = Observable{Matrix{Float64}}(zeros(Float64, 1, 1))
        pupilFigure = Figure(figure_padding=10)
        pupilAx = Axis(pupilFigure[1, 1], aspect = AxisAspect(1.0))
        pupilImage = heatmap!(pupilAx, currentPupilImage, colormap = Symbol(currentPupilColormap[]))
        pupilColorbar = Colorbar(pupilFigure[1, 2], pupilImage)
        hidedecorations!(pupilAx)
        pupilFigureObs = Observable(pupilFigure)

        responseFigure = Figure(figure_padding=5)
        responseAx = Axis(responseFigure[1, 1], xlabel="Wavelength (nm)", ylabel="Response")
        lines!(responseAx, wavelengthFullAp, responseFullAp, label="Full Aperture")
        lines!(responseAx, wavelengthWfs, responseWfs, label="Wavefront Sensor")
        lines!(responseAx, wavelengthTransmission, atmosphericTransmission, label="Atmospheric Transmission")
        Legend(responseFigure[2, 1], responseAx, orientation=:horizontal, halign=:center, tellheight=true)
        responseFigureObs = Observable(responseFigure)

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
            "responseFullAp" => responseFullAp,
            "responseWfs" => responseWfs,
            "wfsType" => wfsType,
            "microlensArrayLength" => microlensArrayLength,
            "numSubaps" => numSubaps,
            "includeAdc" => includeAdc,
            "atmosphericTransmission" => atmosphericTransmission,
            "refWavelength" => refWavelength,
            "Dr0" => Dr0,
            "zenithAngle" => zenithAngle,
            "layerHeights" => layerHeights,
            "windSpeed" => windSpeed,
            "windDirection" => windDirection,
            "randomSeed" => randomSeed,
            "numLayers" => numLayers,
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
            "numWavelengthsSet" => numWavelengthsSet,
            "spacingWavelength" => spacingWavelength,
            "spectralResolution" => spectralResolution,
            "imageSizeFullAp" => imageSizeFullAp,
            "imageSizeWfs" => imageSizeWfs,

            "enableFullAp" => enableFullAp,
            "enableWfs" => enableWfs,
            "enableDiversity" => enableDiversity,

            "availableColormaps" => availableColormaps,
            "currentTargetColormap" => currentTargetColormap,
            "currentImagesColormap" => currentImagesColormap,
            "currentAtmosphereColormap" => currentAtmosphereColormap,
            "currentPupilColormap" => currentPupilColormap,

            "targetFigureObs" => targetFigureObs,
            "imagesFigureObs" => imagesFigureObs,
            "atmosphereFigureObs" => atmosphereFigureObs,
            "pupilFigureObs" => pupilFigureObs,
            "responseFigureObs" => responseFigureObs,
            
            "windowColor" => windowColor,
            "windowText" => windowText,
            "windowDarkColor" => windowDarkColor,
            "saveDirectory" => saveDirectory,
            "runId" => runId,
            
            "numWavelengthsTarget" => numWavelengthsTarget,
            "truthTargetWavelengths" => truthTargetWavelengths,
            "currentTargetWavelength" => currentTargetWavelength,
            "currentImageTimestep" => currentImageTimestep,
            "currentImageSubap" => currentImageSubap,
            "currentImageWavelength" => currentImageWavelength,
            "currentAtmosphereLayer" => currentAtmosphereLayer,
            "currentAtmosphereWavelength" => currentAtmosphereWavelength,
            "currentPupilWavelength" => currentPupilWavelength
        )

        on(windowColor) do color
            targetFigure.scene.backgroundcolor[] = parse(Colorant, color)
            imagesFigure.scene.backgroundcolor[] = parse(Colorant, color)
            atmosphereFigure.scene.backgroundcolor[] = parse(Colorant, color)
            pupilFigure.scene.backgroundcolor[] = parse(Colorant, color)
            responseFigure.scene.backgroundcolor[] = parse(Colorant, color)
        end

        on(windowText) do color
            targetColorbar.ticklabelcolor = parse(Colorant, color)
            targetColorbar.tickcolor = parse(Colorant, color)
            imagesColorbar.ticklabelcolor = parse(Colorant, color)
            imagesColorbar.tickcolor = parse(Colorant, color)
            pupilColorbar.ticklabelcolor = parse(Colorant, color)
            pupilColorbar.tickcolor = parse(Colorant, color)
            atmosphereColorbar.ticklabelcolor = parse(Colorant, color)
            atmosphereColorbar.tickcolor = parse(Colorant, color)

            targetAx.bottomspinecolor = parse(Colorant, color)
            targetAx.leftspinecolor = parse(Colorant, color)
            targetAx.topspinecolor = parse(Colorant, color)
            targetAx.rightspinecolor = parse(Colorant, color)

            imagesAx.bottomspinecolor = parse(Colorant, color)
            imagesAx.leftspinecolor = parse(Colorant, color)
            imagesAx.topspinecolor = parse(Colorant, color)
            imagesAx.rightspinecolor = parse(Colorant, color)

            pupilAx.bottomspinecolor = parse(Colorant, color)
            pupilAx.leftspinecolor = parse(Colorant, color)
            pupilAx.topspinecolor = parse(Colorant, color)
            pupilAx.rightspinecolor = parse(Colorant, color)

            atmosphereAx.bottomspinecolor = parse(Colorant, color)
            atmosphereAx.leftspinecolor = parse(Colorant, color)
            atmosphereAx.topspinecolor = parse(Colorant, color)
            atmosphereAx.rightspinecolor = parse(Colorant, color)

            responseAx.xlabelcolor = parse(Colorant, color)
            responseAx.ylabelcolor = parse(Colorant, color)
            responseAx.bottomspinecolor = parse(Colorant, color)
            responseAx.leftspinecolor = parse(Colorant, color)
            responseAx.topspinecolor = parse(Colorant, color)
            responseAx.rightspinecolor = parse(Colorant, color)
            responseAx.xtickcolor = parse(Colorant, color)
            responseAx.xticklabelcolor = parse(Colorant, color)
            responseAx.ytickcolor = parse(Colorant, color)
            responseAx.yticklabelcolor = parse(Colorant, color)
        end

        function loadTruthImage(pathToImage)
            truthTarget[] = readfits(pathToImage)
            numWavelengthsTarget[] = size(truthTarget[], 3)
            xlims!(targetAx, [0, size(truthTargetImage[], 2)])
            ylims!(targetAx, [0, size(truthTargetImage[], 1)])
            notify(targetFigureObs)
        end

        function loadFullApResponseData(pathToData)
            λ, R = readfile(pathToData)
            wavelengthFullAp.val = λ 
            responseFullAp.val = R
            notify(responseFullAp)
            notify(wavelengthFullAp)
            autolimits!(responseAx)
            notify(responseFigureObs)
        end

        function loadWfsResponseData(pathToData)
            λ, R = readfile(pathToData)
            wavelengthWfs.val = λ 
            responseWfs.val = R
            notify(responseWfs)
            notify(wavelengthWfs)
            autolimits!(responseAx)
            notify(responseFigureObs)
        end

        function loadAtmosphericTransmissionData(pathToData)
            λ, R = readfile(pathToData)
            wavelengthTransmission.val = λ 
            atmosphericTransmission.val = R
            notify(wavelengthTransmission)
            notify(atmosphericTransmission)
            autolimits!(responseAx)
            notify(responseFigureObs)
        end

        function rotTargetCW90()
            imageRotation[] += -π/2
        end

        function rotTargetCCW90()
            imageRotation[] += π/2
        end

        on(imageRotation) do ang
            Makie.rotate!(targetImage, ang)
            autolimits!(targetAx)
            notify(targetFigureObs)
        end

        on(currentTargetColormap) do cmap
            targetImage.colormap = Symbol(cmap)
            notify(targetFigureObs)
        end

        on(currentImagesColormap) do cmap
            imagesImage.colormap = Symbol(cmap)
            notify(imagesFigureObs)
        end

        on(currentAtmosphereColormap) do cmap
            atmosphereImage.colormap = Symbol(cmap)
            notify(atmosphereFigureObs)
        end

        on(currentPupilColormap) do cmap
            pupilImage.colormap = Symbol(cmap)
            notify(pupilFigureObs)
        end

        on(lowerWavelength) do ~
            if lowerWavelength[] == upperWavelength[]
                numWavelengths[] = 1
            end
        end

        on(upperWavelength) do ~
            if lowerWavelength[] == upperWavelength[]
                numWavelengths[] = 1
            end
        end

        function runHyperspectralSpeckle()
            FTYPE = Core.eval(Main, Meta.parse(defaultDatatype[])) 
            DTYPE = Core.eval(Main, Meta.parse(imageDatatype[]))

            wavelength = collect(range(lowerWavelength[], stop=upperWavelength[], length=numWavelengths[]));
            times = collect(0:numTimesteps[]-1) .* exposureTime[]
            observations = []
            ######### Create Full-Ap Detector #########
            diversity = nothing
            if enableDiversity[]
                diversity = Diversity(
                    zernikeIndex[],
                    numWaves[],
                    diversityPeriod[],
                    referenceTime[],
                    FTYPE=FTYPE
                )
            end

            if enableFullAp[]
                wavelengthFullAp[] = isempty(wavelengthFullAp[]) ? wavelength : wavelengthFullAp[]
                response = responseFullAp[] .* ones(numWavelengths[])
                filterFullAp = OpticalElement(λ=wavelengthFullAp[], response=response, FTYPE=FTYPE)
                opticsFullAp = OpticalSystem([filterFullAp], wavelength, FTYPE=FTYPE)
                pixscaleFullAp = fieldOfView[] / imageSizeFullAp[]  # arcsec/pix
                detectorFullAp = Detector(
                    qe=ones(numWavelengths[]) .* quantumEfficiency[],
                    rn=readNoise[],
                    pixscale=pixscaleFullAp,
                    gain=gain[],
                    saturation=wellDepth[],
                    λ=wavelength,
                    λ_nyquist=nyquistWavelength[],
                    exptime=exposureTime[],
                    FTYPE=FTYPE,
                    DTYPE=DTYPE,
                    label="Full Aperture"
                )

                ### Create Full-Ap Observations object ####
                observationsFullAp = Observations(
                    opticsFullAp,
                    detectorFullAp,
                    ζ=zenithAngle[],
                    D=apertureDiameter[],
                    D_inner_frac=obscurationFraction[],
                    times=times,
                    nsubexp=1,
                    nsubaps_side=1,
                    dim=imageSizeFullAp[],
                    diversity=diversity,
                    FTYPE=FTYPE,
                    label="Full Aperture"
                )
                push!(observations, observationsFullAp)
            end

            if enableWfs[]
                wavelengthWfs[] = isempty(wavelengthWfs[]) ? wavelength : wavelengthWfs[]
                response = responseWfs[] .* ones(numWavelengths[])
                filterWfs = OpticalElement(λ=wavelengthWfs[], response=response, FTYPE=FTYPE)
                opticsWfs = OpticalSystem([filterWfs], wavelength, FTYPE=FTYPE)
                pixscaleWfs = pixscaleFullAp .* microlensArrayLength[]  # arcsec/pix
                detectorWfs = Detector(
                    qe=ones(numWavelengths[]) .* quantumEfficiency[],
                    rn=readNoise[],
                    pixscale=pixscaleWfs,
                    gain=gain[],
                    saturation=wellDepth[],
                    λ=wavelength,
                    λ_nyquist=nyquistWavelength[],
                    exptime=exposureTime[],
                    FTYPE=FTYPE,
                    DTYPE=DTYPE,
                    label="Wavefront Sensor"
                )
                apertureArea = pi * (apertureDiameter[] / 2)^2 * (1 - obscurationFraction[]^2)
                observationsWfs = Observations(
                    opticsWfs,
                    detectorWfs,
                    ζ=zenithAngle[],
                    D=apertureDiameter[],
                    area=apertureArea,
                    times=times,
                    nsubexp=1,
                    nsubaps_side=microlensArrayLength[],
                    dim=imageSizeWfs[],
                    build_dim=imageSizeFullAp[],
                    FTYPE=FTYPE,
                    label="Wavefront Sensor"
                )
                numSubaps[] = observationsWfs.masks.nsubaps
                observationsWfs.masks.scale_psfs = observationsFullAp.masks.scale_psfs
                push!(observations, observationsWfs)
            end

            ~, spectrum = solar_spectrum(λ=wavelength)
            irradiance = mag2flux(targetBrightness[], filterFullAp, ζ=zenithAngle[])  # ph / s / m^2
            background = mag2flux(backgroundBrightness[], filterFullAp, ζ=zenithAngle[])  # ph / s / m^2 / arcsec^2
            background *= fieldOfView[]^2  # ph / s / m^2
                        
            object = Object(
                truthTarget[],
                irradiance=irradiance,
                background=background,
                λ=wavelength,
                fov=fieldOfView[],
                object_range=targetRange[], 
                dim=imageSizeFullAp[],
                spectrum=spectrum,
                FTYPE=FTYPE
            )
 
            patches = AnisoplanaticPatches(patchSize[], imageSizeFullAp[], isoplanatic=!simulateAnisoplanatic[], FTYPE=FTYPE)
            
            numLayers[] = length(layerHeights[])
            sampling_nyquist_mperpix = layer_nyquist_sampling_mperpix(apertureDiameter[], imageSizeFullAp[], numLayers[])
            sampling_nyquist_arcsecperpix = layer_nyquist_sampling_arcsecperpix(apertureDiameter[], fieldOfView[], layerHeights[], imageSizeFullAp[])
            transmission = (numWavelengths[] == 1) ? atmosphericTransmission[] : interpolate1d(wavelengthTransmission[], atmosphericTransmission[], wavelength)
            wind = [windSpeed[] windDirection[]]
            atmosphere = Atmosphere(
                wavelength,
                observations, 
                object,
                patches,
                Dr0=Dr0[],
                wind=wind, 
                heights=layerHeights[],
                sampling_nyquist_mperpix=sampling_nyquist_mperpix,
                sampling_nyquist_arcsecperpix=sampling_nyquist_arcsecperpix,
                transmission=transmission,
                λ_nyquist=nyquistWavelength[],
                λ_ref=refWavelength[],
                propagate=propagateLayers[],
                seeds=randomSeed[], 
                FTYPE=FTYPE,
            )

            if enableFullAp[]
                create_detector_images(patches, observationsFullAp, atmosphere, object, build_dim=imageSizeFullAp[], noise=includeNoise[])
            end

            if enableWfs[]
                create_detector_images(patches, observationsWfs, atmosphere, object, build_dim=imageSizeFullAp[], noise=includeNoise[])
            end

            if enableFullAp[]
                currentImage[] = observationsFullAp.images[:, :, 1, 1]
            elseif enableWfs[]
                currentImage[] = observationsWfs.images[:, :, 1, 1]
            end
            
            Makie.rotate!(imagesImage, imageRotation[])
            autolimits!(imagesAx)
            notify(imagesFigureObs)
        end

        ## Julia functions sent to QML
        @qmlfunction loadTruthImage
        @qmlfunction loadFullApResponseData
        @qmlfunction loadWfsResponseData
        @qmlfunction loadAtmosphericTransmissionData
        @qmlfunction rotTargetCW90
        @qmlfunction rotTargetCCW90
        @qmlfunction runHyperspectralSpeckle

        loadqml(joinpath(dirname(@__FILE__), "MainGui.qml"), observables=observables)
        exec()
    end

end
