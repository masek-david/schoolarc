package cz.masci.schoolarc

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class StravaWidgetReceiver : HomeWidgetGlanceWidgetReceiver<StravaWidget>() {
    override val glanceAppWidget = StravaWidget()
}