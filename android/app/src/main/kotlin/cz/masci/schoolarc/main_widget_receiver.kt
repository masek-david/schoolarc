package cz.masci.schoolarc

import HomeWidgetGlanceWidgetReceiver

class MainWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MainWidget>() {
    override val glanceAppWidget = MainWidget()
}