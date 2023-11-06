Shiny.addCustomMessageHandler("dataToPlot", function(dataToPlot) {
    const data = [dataToPlot.time, dataToPlot.value];
    const options = {
        width: 600,
        height: 400,
        series: [{}, { stroke: "red", width: 1 }],
    };

    const uplotElement = document.getElementById("uplot");
    uplotElement.innerHTML = "";
    new uPlot(options, data, uplotElement);
});