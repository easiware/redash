import React from "react";
import PropTypes from "prop-types";
import { includes } from "lodash";
import { getDynamicDateRangeFromString } from "@/services/parameters/DateRangeParameter";
import DynamicDateRangePicker from "@/components/dynamic-parameters/DynamicDateRangePicker";
import ConfigProvider from "antd/lib/config-provider";
import frFR from "antd/lib/locale/fr_FR";

const DYNAMIC_DATE_OPTIONS = [
  {
    name: "Cette semaine",
    value: getDynamicDateRangeFromString("d_this_week"),
    label: () =>
      getDynamicDateRangeFromString("d_this_week")
        .value()[0]
        .format("MMM D") +
      " - " +
      getDynamicDateRangeFromString("d_this_week")
        .value()[1]
        .format("MMM D"),
  },
  {
    name: "Ce mois",
    value: getDynamicDateRangeFromString("d_this_month"),
    label: () =>
      getDynamicDateRangeFromString("d_this_month")
        .value()[0]
        .format("MMMM"),
  },
  {
    name: "Cette année",
    value: getDynamicDateRangeFromString("d_this_year"),
    label: () =>
      getDynamicDateRangeFromString("d_this_year")
        .value()[0]
        .format("YYYY"),
  },
  {
    name: "La semaine dernière",
    value: getDynamicDateRangeFromString("d_last_week"),
    label: () =>
      getDynamicDateRangeFromString("d_last_week")
        .value()[0]
        .format("MMM D") +
      " - " +
      getDynamicDateRangeFromString("d_last_week")
        .value()[1]
        .format("MMM D"),
  },
  {
    name: "Le mois dernier",
    value: getDynamicDateRangeFromString("d_last_month"),
    label: () =>
      getDynamicDateRangeFromString("d_last_month")
        .value()[0]
        .format("MMMM"),
  },
  {
    name: "L'année dernière",
    value: getDynamicDateRangeFromString("d_last_year"),
    label: () =>
      getDynamicDateRangeFromString("d_last_year")
        .value()[0]
        .format("YYYY"),
  },
  {
    name: "Les 7 derniers jours",
    value: getDynamicDateRangeFromString("d_last_7_days"),
    label: () =>
      getDynamicDateRangeFromString("d_last_7_days")
        .value()[0]
        .format("MMM D") + " - Aujourd'hui",
  },
  {
    name: "Les 14 derniers jours",
    value: getDynamicDateRangeFromString("d_last_14_days"),
    label: () =>
      getDynamicDateRangeFromString("d_last_14_days")
        .value()[0]
        .format("MMM D") + " - Aujourd'hui",
  },
  {
    name: "Les 30 derniers jours",
    value: getDynamicDateRangeFromString("d_last_30_days"),
    label: () =>
      getDynamicDateRangeFromString("d_last_30_days")
        .value()[0]
        .format("MMM D") + " - Aujourd'hui",
  },
  {
    name: "Les 60 derniers jours",
    value: getDynamicDateRangeFromString("d_last_60_days"),
    label: () =>
      getDynamicDateRangeFromString("d_last_60_days")
        .value()[0]
        .format("MMM D") + " - Aujourd'hui",
  },
  {
    name: "Les 90 derniers jours",
    value: getDynamicDateRangeFromString("d_last_90_days"),
    label: () =>
      getDynamicDateRangeFromString("d_last_90_days")
        .value()[0]
        .format("MMM D") + " - Aujourd'hui",
  },
  {
    name: "Les 12 derniers mois",
    value: getDynamicDateRangeFromString("d_last_12_months"),
    label: null,
  },
];

const DYNAMIC_DATETIME_OPTIONS = [
  {
    name: "Aujourd'hui",
    value: getDynamicDateRangeFromString("d_today"),
    label: () =>
      getDynamicDateRangeFromString("d_today")
        .value()[0]
        .format("MMM D"),
  },
  {
    name: "Hier",
    value: getDynamicDateRangeFromString("d_yesterday"),
    label: () =>
      getDynamicDateRangeFromString("d_yesterday")
        .value()[0]
        .format("MMM D"),
  },
  ...DYNAMIC_DATE_OPTIONS,
];

function DateRangeParameter(props) {
  const options = includes(props.type, "datetime-range") ? DYNAMIC_DATETIME_OPTIONS : DYNAMIC_DATE_OPTIONS;
  return (
    <ConfigProvider locale={frFR}>
      <DynamicDateRangePicker {...props} dynamicButtonOptions={{ options }} />
    </ConfigProvider>
  );
}

DateRangeParameter.propTypes = {
  type: PropTypes.string,
  className: PropTypes.string,
  value: PropTypes.any, // eslint-disable-line react/forbid-prop-types
  parameter: PropTypes.any, // eslint-disable-line react/forbid-prop-types
  onSelect: PropTypes.func,
};

DateRangeParameter.defaultProps = {
  type: "",
  className: "",
  value: null,
  parameter: null,
  onSelect: () => {},
};

export default DateRangeParameter;
