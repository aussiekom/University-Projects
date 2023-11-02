const locations = [
    { name: "Sněžka", latitude: 50.74, longitude: 15.74 },
    { name: "Pálava", latitude: 48.84, longitude: 16.64 },
    { name: "Komorní hůrka", latitude: 50.10, longitude: 12.34 }
]    

const getForecast = function() {
    const fetches = [];
    for (const location of locations) {
        const url = `https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${location.latitude}&lon=${location.longitude}`;
        fetches.push(fetch(url));
    }
    return Promise.all(fetches)
        .then((responses) => {
            const forecasts = [];
            for (const response of responses) {
                if (response.status < 200 || response.status >= 300) {
                    throw new Error(response.statusText);
                }
                forecasts.push(response.json());
            }
            return Promise.all(forecasts);
        })
        .then(forecasts => {
            const results = [];
            for (const forecast of forecasts) {
                
                results.push(forecast.properties.timeseries[0].data.instant.details.air_temperature);
            }
            Shiny.setInputValue("temperatures", results);
            return results;
        })
        .catch((error) => {
            console.error(error);
        })
}

getForecast();