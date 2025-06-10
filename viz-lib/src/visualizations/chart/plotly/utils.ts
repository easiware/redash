import { isUndefined } from "lodash";
import moment from "moment";
// @ts-expect-error ts-migrate(7016) FIXME: Could not find a declaration file for module 'plot... Remove this comment to see the full error message
import plotlyCleanNumber from "plotly.js/src/lib/clean_number";

export function cleanNumber(value: any) {
  return isUndefined(value) ? value : plotlyCleanNumber(value);
}

export function getSeriesAxis(series: any, options: any) {
  const seriesOptions = options.seriesOptions[series.name] || { type: options.globalSeriesType };
  if (seriesOptions.yAxis === 1 && (!options.series.stacking || seriesOptions.type === "line")) {
    return "y2";
  }
  return "y";
}

export function normalizeValue(value: any, axisType: any, dateTimeFormat = "YYYY-MM-DD HH:mm:ss") {
  if (axisType === "datetime" && moment.utc(value).isValid()) {
    value = moment.utc(value);
  }
  if (moment.isMoment(value)) {
    return value.format(dateTimeFormat);
  }
  return value;
}

// Hack réparant l'ordre des dates sur l'abscisse des graphes avec plusieurs séries de type "line".
export function normalizeValueForSorting(value: any, axisType: any, dateTimeFormat = "YYYY-MM-DD HH:mm:ss") {
  if (axisType === "datetime" && moment.utc(value).isValid()) {
    value = moment.utc(value);
  }
  if (moment.isMoment(value)) {
    return value.format(dateTimeFormat);
  }

  if (typeof value !== "string") {
    return value;
  }

  const endsInYearRegex = /\d{4}$/m;

  if (endsInYearRegex.test(value)) {
    // On doit retraduire les mois vers l'anglais pour que les dates soient parsées correctement.
    // Dès lors que les 3 premières lettres correspondent à l'anglais, le constructeur Date parse correctement (Jan, Mar, Sep, Oct, Nov).
    const replaced = value
      .replace("Fév", "Feb")
      .replace("Avr", "Apr")
      .replace("Mai", "May")
      .replace("Juin", "Jun")
      .replace("Juil", "Jul")
      .replace("Août", "Aug")
      .replace("Déc", "Dec");

    const date = new Date(replaced);
    const time = date.valueOf();

    if (Number.isNaN(time)) {
      console.warn("Failed to parse string to date in x axis: ", value); // eslint-disable-line no-console
      return value;
    }

    return time;
  }

  const frenchMonths = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  ];

  if (frenchMonths.includes(value)) {
    return frenchMonths.indexOf(value);
  }

  return value;
}
