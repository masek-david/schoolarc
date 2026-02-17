package cz.masci.schoolarc

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class MainWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MainWidget>() {
    override val glanceAppWidget = MainWidget()
}