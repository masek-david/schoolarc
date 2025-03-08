package es.antonborri.home_widget_example.glance

import HomeWidgetGlanceWidgetReceiver
import StravaWidget

class StravaWidgetReceiver : HomeWidgetGlanceWidgetReceiver<StravaWidget>() {
    override val glanceAppWidget = StravaWidget()
}