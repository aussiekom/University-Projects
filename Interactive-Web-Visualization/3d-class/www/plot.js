Shiny.addCustomMessageHandler("plotColors", function(colors) {
    const dygraphsElement = document.getElementById("dygraph"); // R output ID
    if (dygraphsElement) {
        const dygraphsWidget = window.HTMLWidgets.getInstance(dygraphsElement);
        if (dygraphsWidget) {
            const dygraphObject = dygraphsWidget.dygraph;
            dygraphObject.updateOptions({ colors: colors });
        }
    }
});

const drawHighlights = function(canvas, area, plot) {
    if (plot.numColumns() > 1) {
        canvas.fillStyle = "#FFFF00";
        for (let row = 0; row < plot.numRows(); row++) {
            if (plot.getValue(row, 1) > plot.currentTemperatures[0]) {
                const xValue = plot.getValue(row, 0);
                const xValueBefore = plot.getValue(row === 0 ? 0 : row - 1, 0);
                const left = plot.toDomXCoord(xValueBefore);
                const right = plot.toDomXCoord(xValue);
                canvas.fillRect(left, area.y, right - left, area.h);
            }
        }
    }
}

// async/await version
const highlightTemperaturesAsync = async function(canvas, area, plot) {
    if (!plot.currentTemperatures) {
        try {
            plot.currentTemperatures = await getForecastAsync();
        } catch {
            console.error(error);
        }
    }
    drawHighlights(canvas, area, plot);
};

// then/catch version
const highlightTemperatures = function(canvas, area, plot) {
    if (!plot.currentTemperatures) {
        getForecast().then(temperatures => {
            plot.currentTemperatures = temperatures;
            drawHighlights(canvas, area, plot);
        }).catch(error => {
            console.error(error);
        });
    } else {
        drawHighlights(canvas, area, plot);
    }
};