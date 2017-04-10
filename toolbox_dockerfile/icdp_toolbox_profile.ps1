function Run-DACDToolbox {
    if ($(docker ps -qa --filter=name=dacd_reference_toolbox) -eq $null) {
        docker run -it --name dacd_reference_toolbox vancluever/dacd_reference_toolbox
    } else {
        docker start -ia dacd_reference_toolbox
    }
}

New-Alias dacd_toolbox Run-DACDToolbox

